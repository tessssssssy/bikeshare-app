class PaymentsController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:webhook]
    def new
      @booking = Booking.find(params[:id])
    end
    def get_stripe_id
      p params
      @booking = Booking.find(params[:id])
        session_id = Stripe::Checkout::Session.create(
          payment_method_types: ['card'],
          customer_email: current_user.email,
          line_items: [{
            name: 'booking',
            description: 'a booking',
            amount: 1000,
            currency: 'aud',
            quantity: 1,
          }],
          payment_intent_data: {
            metadata: {
              user_id: current_user.id,
              booking_id: @booking.id
            }
          },
          success_url: "#{root_url}payments/success?userId=#{current_user.id}&bookingId=#{@booking.id}",
          cancel_url: "#{root_url}listings"
        ).id
        p session_id
        render :json => {id: session_id, stripe_public_key: Rails.application.credentials.dig(:stripe, :public_key)}
      end
      def success
      end
      def webhook
        payment_id = params[:data][:object][:payment_intent]
        # booking_id = params[:data][:object][:metadata][:booking_id]
        # user_id = params[:data][:object][:metadata][:user_id]
        payment = Stripe::PaymentIntent.retrieve(payment_id)
        booking_id = payment.metadata.booking_id
        p booking_id
        user_id = payment.metadata.user_id
        booking = Booking.find(booking_id)
        booking.confirmed = true
        booking.save
      end
end

