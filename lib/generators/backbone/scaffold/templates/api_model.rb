module ApiV1::<%= class_name %>
  extend ActiveSupport::Concern

  included do

    api_accessible :base do |t|
      t.add :id
<% attributes.each do |attribute| -%>
      t.add :<%= attribute.name %>
<% end -%>
    end

    api_accessible :list, :extend => :base do |t|
    end

    api_accessible :public, :extend => :list do |t|
    end

  end

end
