# frozen_string_literal: true
class CatalogController < ApplicationController

  include Blacklight::Catalog

  configure_blacklight do |config|
    ## Class for sending and receiving requests from a search index
    # config.repository_class = Blacklight::Solr::Repository
    #
    ## Class for converting Blacklight's url parameters to into request parameters for the search index
    # config.search_builder_class = ::SearchBuilder
    #
    ## Model that maps search index responses to the blacklight response model
    # config.response_model = Blacklight::Solr::Response
    config.wayback_url = WAYBACK_CONFIG['base_url'] #'http://kb-test-way-001.kb.dk:8080/jsp/QueryUI/Redirect.jsp?url=[url]&time=[wayback_date]'

    ## Default parameters to send to solr for all search-like requests. See also SearchBuilder#processed_parameters
    config.default_solr_params = {
        :qt => 'search',
        :rows => 25,
        :defType => 'edismax',
    }

    # solr path which will be added to solr base url before the other solr params.
    #config.solr_path = 'select'
    #config.document_solr_path = 'get'

    # items to my_show per page, each number in the array represent another option to choose from.
    config.per_page = [25,25,100,250]

    # solr field configuration for search results/index views
    config.index.title_field = 'url'

    # solr field configuration for document/my_show views
    config.show.title_field = 'title'
    config.show.domain_field= 'domain'

    config.add_facet_field 'crawl_year', :label => 'Crawl Year', :single => true, sort: 'index', solr_params: { 'facet.mincount' => 1 }
    config.add_facet_field 'domain', :label => 'Domain', :single => true, :limit => 10, solr_params: { 'facet.mincount' => 1 }
    config.add_facet_field 'content_type_norm', :label => 'Content Type', :single => true, :limit => 10, solr_params: { 'facet.mincount' => 1 }
    config.add_facet_field 'public_suffix', :label => 'Public Suffix', :single => true, :limit => 10, solr_params: { 'facet.mincount' => 1 }

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display

    config.add_index_field 'id', :label => 'Complete index', :helper_method => :get_id_show_link
    config.add_index_field 'content_type', :label => 'Mime Type'
    config.add_index_field 'content_type_served', :label => 'Full Content Type'
    config.add_index_field 'crawl_date', :label => 'Crawl Date'
    config.add_index_field 'content_text', :label => 'Content', :helper_method => :get_simple_context_text
    config.add_index_field 'domain', :label => 'Domain'
    config.add_index_field 'url', :label => 'Harvested URL', :helper_method => :get_url_link

    # solr fields to be displayed in the my_show (single result) view
    #   The ordering of the field names is the order of the display

    config.add_show_field 'crawl_year', :label => 'Wayback URL', :helper_method => :get_wayback_link
    config.add_show_field 'title', :label => 'Title'
    config.add_show_field 'crawl_date', :label => 'Crawl Date'
    config.add_show_field 'url', :label => 'Harvested URL'


    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.

    # config.add_search_field 'all_fields', label: 'All Fields'


    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.

    config.add_search_field 'all_fields', :label => 'All Fields' do |field|
      field.solr_local_parameters = {
          :qf => 'title^100 content_text^10 url^3 text domain',
          :pf => 'title^100 content_text^10 url^3 text domain'
      }
    end

    config.add_search_field('url', :label => 'URL/domain') do |field|
      field.solr_parameters = { :'spellcheck.dictionary' => 'url' }
      field.solr_local_parameters = {
          :qf => 'url^2 domain',
          :pf => 'url^2 domain'
      }
    end

    config.add_search_field('text', :label => 'Text') do |field|
      field.solr_parameters = { :'spellcheck.dictionary' => 'text' }
      field.solr_local_parameters = {
          :qf => 'title^5 content_text',
          :pf => 'title^5 content_text'
      }
    end

    config.add_search_field('links', :label => 'Links') do |field|
      field.solr_parameters = { :'spellcheck.dictionary' => 'links' }
      field.solr_local_parameters = {
          :qf => 'links_hosts links_domains',
          :pf => 'links_hosts links_domains'
      }
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    # config.add_sort_field 'score desc, pub_date_sort desc, title_sort asc', label: 'relevance'
    # config.add_sort_field 'pub_date_sort desc, title_sort asc', label: 'year'
    # config.add_sort_field 'author_sort asc, title_sort asc', label: 'author'
    # config.add_sort_field 'title_sort asc, pub_date_sort desc', label: 'title'
    #
    # # If there are more than this many search results, no spelling ("did you
    # # mean") suggestion is offered.
    # config.spell_max = 5
    #
    # # Configuration for autocomplete suggestor
    # config.autocomplete_enabled = true
    # config.autocomplete_path = 'suggest'
    config.add_sort_field 'score desc', :label => 'relevance'
    config.add_sort_field 'crawl_date desc', :label => 'crawl date (decending)'
    config.add_sort_field 'crawl_date asc', :label => 'crawl date (ascending)'
    config.add_sort_field 'domain desc, url desc, crawl_date desc', :label => 'URL (a-z)'
    config.add_sort_field 'domain asc, url asc, crawl_date desc', :label => 'URL (z-a)'
    config.add_sort_field 'content_type_norm asc', :label => 'content type (a-z)'
    config.add_sort_field 'content_type_norm desc', :label => 'content type (z-a)'

    # Remove all actions from the navbar
    config.navbar.partials = {}

    # get single document from the solr index
    def show
      deprecated_response, @document = search_service.fetch(params[:id])
      @response = ActiveSupport::Deprecation::DeprecatedObjectProxy.new(deprecated_response, 'The @response instance variable is deprecated; use @document.response instead.')

      respond_to do |format|
        format.html { @search_context = setup_next_and_previous_documents }
        format.json { render json: { response: { document: @document } } }

        additional_export_formats(@document, format)
      end
    end
  end

end
