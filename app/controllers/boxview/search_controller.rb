class Boxview::SearchController < Boxview::BaseController

  def fi_results
    search_for fi_fulltext_klasses
  end

  def vt_results
    search_for vt_fulltext_klasses
  end

  private
    def search_for(klasses)
      @q = params[:q].try(:strip)
      # Note: contrary to what the documentation says, 
      # it seems you _have_ to specify the block argument.
      @search = SOLR.search(*klasses) do |s|
        s.keywords @q
        s.order_by :boxview_title
      end
      render 'results'
    end

    def pi_fulltext_klasses
      [SOLR::PiIllustratedMdCard, SOLR::PiIllustrationCard, SOLR::PiLetterIllustrationCard, SOLR::PiTextCard]
    end

    def fi_fulltext_klasses
      [SOLR::FiTextCard,
       SOLR::FiAnimalCard,
       SOLR::FiCharacterCard,
       SOLR::FiDeityCard,
       SOLR::FiParadeCartCard,
       SOLR::FiThroneCard,
       SOLR::FiVehicleCard,
       SOLR::FiEpisodeCard]
    end

    def vt_fulltext_klasses
      [SOLR::VtHandwrittenTextCard, SOLR::VtPrintedTextCard, SOLR::VtLetter]
    end

    def bg_fulltext_klasses
      []
    end
  # end private
end
