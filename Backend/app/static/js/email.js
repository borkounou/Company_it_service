

document.getElementById('emailForm').addEventListener('submit',function(event){
    event.preventDefault();
    let userEmail = document.getElementById('email').value;
    let userName = document.getElementById('name').value;
    let userMessage = document.getElementById('message').value;

    Email.send({
        SecureToken : "f99d9a5c-b8ab-42b2-b33b-80e64e285942",
        To : 'cherifhassan1710@gmail.com',
        From : 'visitor@borkounou.com',
        Subject : "One customer send you a message",
        Body : "Send by: " + userName + "<br>With an email: " + userEmail+"." + "<br>Message: " + userMessage
    }).then(
      message => alert(message)
    );

    this.reset();
});



