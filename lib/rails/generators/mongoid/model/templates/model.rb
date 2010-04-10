class <%= class_name %><%= " < #{options[:parent].classify}" if options[:parent] %>

<% unless options[:parent] -%>
  include Mongoid::Document
<% end -%>
<% if options[:timestamps] -%>
  include Mongoid::Timestamps
<% end %>

<%= 'include Mongoid::Versioning' if options[:versioning] %>

<% attributes.reject{|attr| attr.reference?}.each do |attribute| -%>
  field :<%= attribute.name %>, :type => <%= attribute.type_class %>
<% end -%>

<% attributes.select{|attr| attr.reference? }.each do |attribute| -%>
  belongs_to :<%= attribute.name%>, :inverse_of => :<%= class_name.tableize %>
<% end -%>


end