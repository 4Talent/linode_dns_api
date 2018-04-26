module LinodeDnsApi
  require "httparty"
  require "byebug"

  class Domain
    APIKEY = ""

    def initialize(id, name)
      @id = id
      @name = name
      @resources = ResourceProxy.new(self, Resource.list(self))
    end

    def id() @id end
    def resources() @resources end

    def self.set_api_key
      self.class.send(:remove_const, APIKEY)
      self.class.const_set(APIKEY, value)
    end

    def self.create(name)
      # TODO
      rescue "Not implemented yed!!"
    end

    def self.list
      request = HTTParty.get("https://api.linode.com/?api_key=#{APIKEY}&api_action=domain.list")
      domains = JSON.parse(request.body).to_hash
      domains["DATA"].map { |d| d["DOMAIN"]}
    end

    def self.get(domain_name)
      request = HTTParty.get("https://api.linode.com/?api_key=#{APIKEY}&api_action=domain.list")
      domains = JSON.parse(request.body).to_hash

      domains["DATA"].each do |d|
        return Domain.new(d["DOMAINID"], domain_name) if d["DOMAIN"] == domain_name
      end
    end

    class ResourceProxy
      instance_methods.each do |m|
        undef_method(m) unless m =~ /(^__|^nil\?|^send$|^object_id$)/
      end

      def initialize(domain, array)
        @domain = domain
        @target = array
      end

      def respond_to?(symbol, include_priv=false)
        @target.respond_to?(symbol, include_priv)
      end

      def <<(object)
        object.is_a?(Array) ? @target += object : @target << object
      end

      def new(name, target, type="A")
        _resource = @domain.resources.find { |r| r.name == name }
        if _resource
          puts "the resource #{name} is already exist" if _resource
          return _resource
        end
        self << Resource.create(@domain, name, target, type)
        puts "Resource #{name} was created correctly!"
      end

      def delete(resource_name)
        resource = @domain.resources.detect { |r| r.name == resource_name}
        resource ? resource.delete : puts "Resource not found!"
      end

      private
        def method_missing(method, *args, &block)
          @target.send(method, *args, &block)
        end
    end

    class Resource
      def initialize(id, name, type, target, domain)
        @id, @name, @type, @target, @domain = id, name, type, target, domain
      end

      def id() @id end
      def name() @name end
      def type() @type end
      def target() @target end

      def self.create(domain, name, target=nil, type="A")
        params = {}
        params[:DomainId] = domain.id
        params[:Name] = name
        params[:Target] = target
        params[:Type] = type

        request = HTTParty.post("https://api.linode.com/?api_key=#{APIKEY}&api_action=domain.resource.create", body: params)
        resource = JSON.parse(request.body).to_hash
        return Resource.new(resource["DATA"], name, type, target, domain)
      end

      def self.list(domain)
        request = HTTParty.get("https://api.linode.com/?api_key=#{APIKEY}&api_action=domain.resource.list&domainid=#{domain.id}")
        resources = JSON.parse(request.body).to_hash
        return resources["DATA"].map do |r|
          Resource.new(r["RESOURCEID"], r["NAME"], r["TYPE"], r["TARGET"], domain)
        end
      end

      def delete
        request = HTTParty.post("https://api.linode.com/?api_key=#{APIKEY}&api_action=domain.resource.delete&domainid=#{@domain.id}", body: { ResourceID: @id })
        @domain.resources.delete(self)
        puts "Resource #{name} was deleted correctly!"
      end
    end
  end
end
