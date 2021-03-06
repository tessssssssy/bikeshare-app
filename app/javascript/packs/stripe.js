import '@stripe/stripe-js';


const button = document.getElementById("stripe")
button.addEventListener("click", (e) => {
  const id = location.pathname.split("/")[4]
  console.log(id)
  fetch(`/payments/session?id=${id}`)
  .then((res) => res.json())
  .then((data) => {
    const stripe = Stripe(data.stripe_public_key);
    stripe.redirectToCheckout({
      sessionId: data.id
    })
  })
})

