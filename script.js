function changeCompanyProfile() {
  var name = document.getElementById("name").value;
  var email = document.getElementById("email").value;
  var phone = document.getElementById("phone").value;
  var address = document.getElementById("address").value;
  console.log({
    name: name,
    email: email,
    phone: phone,
    address: address,
  });

  document.getElementById("nameValue").innerHTML = name;
  document.getElementById("emailValue").innerHTML = email;
  document.getElementById("phoneValue").innerHTML = phone;
  document.getElementById("addressValue").innerHTML = address;
}
