class FirbMemoryDepiction < TaliaCore::Source

  singular_property :name, N::TALIA.name
  
  extend RandomId

  singular_property :anastatica, N::DCT.isPartOf


end