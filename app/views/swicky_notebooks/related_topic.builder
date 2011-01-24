TaliaCore::ActiveSourceParts::Xml::RdfBuilder.open(:builder => xml) do |builder|
  #builder.write_for_triples(builder.prepare_triples(@triples))
  builder.write_triples @triples
end