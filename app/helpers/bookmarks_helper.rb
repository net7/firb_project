module BookmarksHelper
    
    def my_notebooks_select
        # TODO: get this from the RDF
        foo = @my_notebooks.collect{|a| ["#{a.title}", a.uri.to_s]}
        foo.sort
        # [["Notebook 1", 'gigigi'], ["Notebook numero 2", 'lalalala']]
    end

end
