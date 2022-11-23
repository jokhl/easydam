class SearchController < ApplicationController
  def create
    rawQuery = params[:query].permit!
    page_number = params[:page] || 1
    
    #@hits = Asset.search "*", where: query[:where], page: page, per_page: 20
    search = AssetQueryBuilder.new rawQuery

    took = Benchmark.realtime do
      @hits = search.execute(page_number: page_number)
    end

    puts search.execute.to_sql

    total = @hits.page(page_number).total_count
    count_per_page = @hits.page(page_number).size
    total_pages = @hits.page(page_number).total_pages
    current_page = @hits.page(page_number).current_page
    offset = @hits.page(page_number).offset_value

    resp = {
      pagination: {
        took: (took * 1000).round,
        total: total,
        count_per_page: count_per_page,
        total_pages: total_pages,
        current_page: current_page,
        offset: offset
      },
      hits: @hits
    }

    render json: resp
  end
end
