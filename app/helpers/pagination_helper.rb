module PaginationHelper
  def pagy_nav(pagy)
    html = %(<div class="join" aria-label="Pages">)

    html << if pagy.prev
              %(<a href="#{pagy_url_for(pagy, pagy.prev)}" class="join-item btn" aria-label="Previous">«</a>)
            else
              %(<button class="join-item btn" aria-disabled="true" aria-label="Previous">«</button>)
            end

    pagy.series.each do |item|
      case item
      when Integer
        html << %(<a href="#{pagy_url_for(pagy, item)}" class="join-item btn">#{item}</a>)
      when String
        html << %(<button class="join-item btn btn-active" aria-disabled="true" aria-current="page">#{item}</button>)
      when :gap
        html << %(<button class="join-item btn btn-disabled" aria-disabled="true">...</button>)
      end
    end

    html << if pagy.next
              %(<a href="#{pagy_url_for(pagy, pagy.next)}" class="join-item btn" aria-label="Next">»</a>)
            else
              %(<button class="join-item btn" aria-disabled="true" aria-label="Next">»</button>)
            end

    html << %(</div>)

    html.html_safe # rubocop:disable Rails/OutputSafety
  end
end
