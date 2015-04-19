require 'http_router'
require 'tilt'

module Racket
  class Router

    def initialize
      @router = HttpRouter.new
      @actions_by_controller = {}
      @templates_by_path = {}
    end

    # Caches available actions for each controller class. This also works for controller classes
    # that inherit from other controller classes.
    def cache_actions(klass)
      actions = Set.new
      current = klass
      while current < Controller
        actions.merge(current.instance_methods(false))
        current = current.superclass
      end
      @actions_by_controller[klass] = actions.to_a
    end

    def map(path, klass)
      @router.add(path).to(klass)
      cache_actions(klass)
    end

    # @todo: Allow the user to set custom handlers for different errors
    def render_404(message = '404 Not found')
      [404, { 'Content-Type' => 'text/plain' }, message]
    end

    def template(path, num_params)
      url_path = path
      1.upto(num_params) { url_path = File.dirname(url_path) }
      return @templates_by_path[url_path] if @templates_by_path.key?(url_path)
      file_path = File.join(Application.options[:view_dir], url_path)
      action = File.basename(file_path)
      file_path = File.dirname(file_path)
      return @templates_by_path[url_path] = nil unless
        File.exists?(file_path) && File.directory?(file_path)
      Dir.chdir(file_path) do
        files = Dir.glob("#{action}.*")
        if files.empty?
          # Look for default view
          files = Dir.glob("_default.*")
          return @templates_by_path[url_path] = nil if files.empty?
          return  @templates_by_path[url_path] = File.join(file_path, files.first)
        end
        @templates_by_path[url_path] = File.join(file_path, files.first)
      end
    end

    # Renders a template or (if template is nil or false) a result
    #
    # @param [Racket::Controller] target
    # @param [String] template
    # @param [String] str
    # @return nil
    def render_template_or_string(target, template, str = nil)
      target.response.write(template ? Tilt.new(template).render(target) : str.to_s)
      nil
    end

    def route(env)
      # Find controller in map
      # If controller exists, call it
      # Otherwise, send a 404
      matching_routes = @router.recognize(env)
      unless matching_routes.first.nil?
        target_klass = matching_routes.first.first.route.dest
        target = target_klass.new
        target.extend(Current.get(env))
        params = matching_routes.first.first.param_values.first.reject { |e| e.empty? }
        action = params.empty? ? :index : params.shift.to_sym
        # Check if action is available on target
        return render_404 unless @actions_by_controller[target_klass].include?(action)
        meth = target.method(action)
        if meth.arity.zero?
          result = meth.call
        else
          result = meth.call(params[0...meth.arity])
        end
        template = template(target.request.path, params.length)
        render_template_or_string(target, template, result)
        target.response.finish
      else
        render_404
      end
    end

  end
end
