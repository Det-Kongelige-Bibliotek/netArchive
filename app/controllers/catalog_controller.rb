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

    # items to show per page, each number in the array represent another option to choose from.
    config.per_page = [25,25,100,250]

    # solr field configuration for search results/index views
    config.index.title_field = 'url'

    #NKH config.index.display_type_field = 'format'
    #config.index.thumbnail_field = 'thumbnail_path_ss'

    # solr field configuration for document/show views
    config.show.title_field = 'title'
    #Next line NKH
    config.show.domain_field= 'domain'
    #config.show.display_type_field = 'format'
    #config.show.thumbnail_field = 'thumbnail_path_ss'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar
    #
    # set :index_range to true if you want the facet pagination view to have facet prefix-based navigation
    #  (useful when user clicks "more" on a large facet and wants to navigate alphabetically across a large set of results)
    # :index_range can be an array or range of prefixes that will be used to create the navigation (note: It is case sensitive when searching values)
## NKH Start
    #config.add_facet_field 'format', label: 'Format'
    #config.add_facet_field 'pub_date', label: 'Publication Year', single: true
    #config.add_facet_field 'subject_topic_facet', label: 'Topic', limit: 20, index_range: 'A'..'Z'
    #config.add_facet_field 'language_facet', label: 'Language', limit: true
    #config.add_facet_field 'lc_1letter_facet', label: 'Call Number'
    #config.add_facet_field 'subject_geo_facet', label: 'Region'
    #config.add_facet_field 'subject_era_facet', label: 'Era'

    #config.add_facet_field 'example_pivot_field', label: 'Pivot Field', :pivot => ['format', 'language_facet']

    #config.add_facet_field 'example_query_facet_field', label: 'Publish Date', :query => {
    #   :years_5 => { label: 'within 5 Years', fq: "pub_date:[#{Time.zone.now.year - 5 } TO *]" },
    #   :years_10 => { label: 'within 10 Years', fq: "pub_date:[#{Time.zone.now.year - 10 } TO *]" },
    #   :years_25 => { label: 'within 25 Years', fq: "pub_date:[#{Time.zone.now.year - 25 } TO *]" }
    #}
    config.add_facet_field 'crawl_year', :label => 'Crawl Year', :single => true, sort: 'index', solr_params: { 'facet.mincount' => 1 }
    config.add_facet_field 'domain', :label => 'Domain', :single => true, :limit => 10, solr_params: { 'facet.mincount' => 1 }
    config.add_facet_field 'content_type_norm', :label => 'Content Type', :single => true, :limit => 10, solr_params: { 'facet.mincount' => 1 }
    config.add_facet_field 'public_suffix', :label => 'Public Suffix', :single => true, :limit => 10, solr_params: { 'facet.mincount' => 1 }

    ##NKH End

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
## NKH Start
    #config.add_index_field 'title_display', label: 'Title'
    #config.add_index_field 'title_vern_display', label: 'Title'
    #config.add_index_field 'author_display', label: 'Author'
    #config.add_index_field 'author_vern_display', label: 'Author'
    #config.add_index_field 'format', label: 'Format'
    #config.add_index_field 'language_facet', label: 'Language'
    #config.add_index_field 'published_display', label: 'Published'
    #config.add_index_field 'published_vern_display', label: 'Published'
    #config.add_index_field 'lc_callnum_display', label: 'Call number'
    config.add_index_field 'content_type_norm'
    config.add_index_field 'crawl_date', :label => 'Crawl Date'
    config.add_index_field 'id', :label => 'Complete index', :helper_method => :get_id_show_link
    config.add_index_field 'title'

## NKH End

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
## NKH Start
    #config.add_show_field 'title_display', label: 'Title'
    #config.add_show_field 'title_vern_display', label: 'Title'
    #config.add_show_field 'subtitle_display', label: 'Subtitle'
    #config.add_show_field 'subtitle_vern_display', label: 'Subtitle'
    #config.add_show_field 'author_display', label: 'Author'
    #config.add_show_field 'author_vern_display', label: 'Author'
    #config.add_show_field 'format', label: 'Format'
    #config.add_show_field 'url_fulltext_display', label: 'URL'
    #config.add_show_field 'url_suppl_display', label: 'More Information'
    #config.add_show_field 'language_facet', label: 'Language'
    #config.add_show_field 'published_display', label: 'Published'
    #config.add_show_field 'published_vern_display', label: 'Published'
    #config.add_show_field 'lc_callnum_display', label: 'Call number'
    #config.add_show_field 'isbn_t', label: 'ISBN'

    config.add_show_field 'crawl_year', :label => 'Wayback URL', :helper_method => :get_wayback_link
    config.add_show_field 'title', :label => 'Title'
    config.add_show_field 'crawl_date', :label => 'Crawl Date'
    config.add_show_field 'url', :label => 'Harvested URL'

    ## NKH End

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


## NKH Start
    #config.add_search_field('title') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params.
      #field.solr_parameters = {
      #  'spellcheck.dictionary': 'title',
      #  qf: '${title_qf}',
      #  pf: '${title_pf}'
    config.add_search_field 'all_fields', :label => 'All Fields' do |field|
      field.solr_local_parameters = {
          :qf => 'title^100 content_text^10 url^3 text domain',
          :pf => 'title^100 content_text^10 url^3 text domain'
## NKH End
      }
    end
## NKH Start

    config.add_search_field('url', :label => 'URL/domain') do |field|
      field.solr_parameters = { :'spellcheck.dictionary' => 'url' }
      field.solr_local_parameters = {
          :qf => 'url^2 domain',
          :pf => 'url^2 domain'
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

    # get single document from the solr index
    def show
      # Decodes the id: '/' transformed from '&#47;'
      id = params[:id].gsub('&#47;', '/')
      @response, @document = get_solr_response_for_doc_id id, {:q => "id:#{id}"}
      respond_to do |format|
        format.html {setup_next_and_previous_documents}
        format.json { render json: {response: {document: @document}}}
        # Add all dynamically added (such as by document extensions)
        # export formats.
        @document.export_formats.each_key do | format_name |
          # It's important that the argument to send be a symbol;
          # if it's a string, it makes Rails unhappy for unclear reasons.
          format.send(format_name.to_sym) { render :text => @document.export_as(format_name), :layout => false }
        end
      end
    end

## NKH End

  end
end
