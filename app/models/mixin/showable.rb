module Mixin::Showable
  def _showable_in
    @showable_in
  end

  def showable_in(*args)
    @showable_in = [*args]
  end

  def showable_in?(klass)
    @showable_in.include? klass
  end
end
