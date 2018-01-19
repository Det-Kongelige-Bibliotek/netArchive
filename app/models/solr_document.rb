# frozen_string_literal: true
class SolrDocument
  include Blacklight::Solr::Document

  extension_parameters[:marc_source_field] = :marc_display
  extension_parameters[:marc_format_type] = :marcxml
  use_extension( Blacklight::Solr::Document::Marc) do |document|
    document.key?( :marc_display  )
  end

  field_semantics.merge!(
      :title => "title_display",
      :author => "author_display",
      :language => "language_facet",
      :format => "format"
  )
end
