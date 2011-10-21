module BackboneResponses

  def self.included(base)
    base.send :include, InstanceMethods
    base.send :extend, ClassMethods
  end

  module ClassMethods
    # Add class methods here
  end

  module InstanceMethods
    # Add instance methods here

    def index
      collection_public_attributes

      respond_to do |format|
        format.html
        format.json {
          render :json => instance_variable_get("@#{controller_name}")
        }
      end
    end

    def update
      update! do |format|
        format.json do
          render :json => resource_public_attributes
        end
      end
    end

    def create
      create! do |format|
        format.json do
          render :json => resource_public_attributes
        end
      end
    end

    def show
      respond_to do |format|
        format.json do
          render :json => resource_public_attributes
        end
      end
    end

    protected

      def collection
        if paginate?
          resources = end_of_association_chain.paginate(
            :page => (params[:page] || 1), :per_page => resources_per_page)
        else
          resources = end_of_association_chain.all
        end
        instance_variable_set("@#{controller_name}" , resources)
      end

      def resource_public_attributes
        model = controller_name.classify.constantize
        if model.respond_to?(:acts_as_api?) and model.acts_as_api? and model.respond_to?(:"api_accessible_#{api_resource_template}")
          resource.as_api_response(:"#{api_resource_template}")
        else
          resource
        end
      end

      def collection_public_attributes
        model     = controller_name.classify.constantize
        resources = collection

        if model.respond_to?(:acts_as_api?) and model.acts_as_api? and model.respond_to?(:"api_accessible_#{api_collection_template}")
          allowed_keys = resources.collect{|o| o.as_api_response(:"#{api_collection_template}")}
        else
          allowed_keys = resources
        end

        if paginate?
          per_page      = resources.per_page
          total_entries = resources.total_entries
          total_pages   = (total_entries.to_f / per_page.to_f).ceil

          resources_with_pagination = {}
          resources_with_pagination[:resources] = allowed_keys
          resources_with_pagination[:pagination] = {
            :current_page  => resources.current_page,
            :per_page      => per_page,
            :total_entries => total_entries,
            :total_pages   => total_pages
          }
          instance_variable_set("@#{controller_name}" , resources_with_pagination)
        else
          instance_variable_set("@#{controller_name}" , allowed_keys)
        end
      end

    end

    def api_collection_template
      "public"
    end

    def api_resource_template
      "public"
    end

    def paginate?
      true
    end

    def resources_per_page
      50
    end

end
