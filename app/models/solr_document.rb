# frozen_string_literal: true
class SolrDocument
  include Blacklight::Solr::Document

## NKH Start

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



# self.unique_key = 'id'

# Email uses the semantic field mappings below to generate the body of an email.
#NKH  SolrDocument.use_extension( Blacklight::Solr::Document::Email )

# SMS uses the semantic field mappings below to generate the body of an SMS email.
#NKH  SolrDocument.use_extension( Blacklight::Solr::Document::Sms )

# DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
# Semantic mappings of solr stored fields. Fields may be multi or
# single valued. See Blacklight::Solr::Document::ExtendableClassMethods#field_semantics
# and Blacklight::Solr::Document#to_semantic_values
# Recommendation: Use field names from Dublin Core
#NKH  use_extension( Blacklight::Solr::Document::DublinCore)

## NKH End
end
