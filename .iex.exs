config = Vimond.Config.from_environment()

create_test_user = fn email ->
  %Vimond.User{
      user_id: nil,
      username: email,
      password: "testuser",
      email: email,
      first_name: "test",
      last_name: "test",
      zip_code: "12345",
      country_code: "FIN",
      year_of_birth: 1999,
      properties: [],
      postal_address: "Teststreet 1234",
      gender: 1,
      email_status: nil,
      mobile_status: nil,
      mobile_number: nil
  }
end
