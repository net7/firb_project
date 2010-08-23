class TaliaUser < TaliaCore::Source

  extend RandomId

  singular_property :name, N::TALIA.user_name
  singular_property :email_address, N::TALIA.user_email_address


  def email=(email)
    self.email_address = email
  end

  def email
    N::URI.from_encoded(self.email_address).to_s
  end

  def self.create_from_name_and_email(name, email_address)
    talia_user = TaliaUser.new
    talia_user.uri = (N::LOCAL.user + '/' + random_id).to_s
    talia_user.name = name

    # TODO: talia uses '@' internally, for now replace it with an _
    # the resulting string is as unique as the original email address
    talia_user.email_address = email_address.sub('@', '_')
    talia_user.save!
  end

  def self.find_by_email(email_address)
    
  end

  def self.find_by_name_and_email(name, email_address)
    # email_address = email_address.to_uri.safe_encoded.to_s
    qry = ActiveRDF::Query.new(TaliaUser).select(:user).distinct
    qry.where(:user, N::RDF.type, N::TALIA.TaliaUser)
    # qry.where(:user, N::TALIA.user_name, name)
    # qry.where(:user, N::TALIA.user_email_address, email_address)

    # TODO: RDF not working as intended? No problem! Dirtiness to the rescue!
    # check why RDF doesnt work and put in place THE better method to get
    # the desider talia user
    ret = nil
    qry.execute.each do |u|
      puts u.inspect
      # TODO: since the .email_address methos replaces .. we do the same
      # then search for it
      if (u.name == name && u.email_address == email_address.sub('@', '_'))
        ret = u
      else
        puts "MAL #{u.name} -- #{u.email_address}"
      end
    end
      
    ret
  end


end