INTERFACE zif_travel_messages
  PUBLIC.

  CONSTANTS:
      c_msgid TYPE symsgid VALUE 'ZMSG_TRAVEL',

    " Dates
      c_begin_date_required TYPE symsgno VALUE '001',
      c_end_date_required TYPE symsgno VALUE '002',
      c_end_before_begin TYPE symsgno VALUE '003',
      c_begin_date_past TYPE symsgno VALUE '004',
      c_end_date_past TYPE symsgno VALUE '005',

    " Agency
      c_agency_required TYPE symsgno VALUE '006',
      c_agency_not_found TYPE symsgno VALUE '007',

    " Customer
      c_customer_required TYPE symsgno VALUE '008',
      c_customer_not_found TYPE symsgno VALUE '009',

    " Currency
      c_currency_required TYPE symsgno VALUE '010',
      c_currency_not_found TYPE symsgno VALUE '011',

    " Status
      c_status_new TYPE symsgno VALUE '012',
      c_status_planned TYPE symsgno VALUE '012',
      c_already_cancelled TYPE symsgno VALUE '014',
      c_invalid_status_transition TYPE symsgno VALUE '016',

    " Discount
      c_discount_error TYPE symsgno VALUE '013',

    "Booking Fee
      c_booking_fee_invalid TYPE symsgno VALUE '015',

    "FlightPrice
      c_flight_price_invalid TYPE symsgno VALUE '017',

    "BookingDate
      c_booking_date_required TYPE symsgno VALUE '018',
      c_booking_date_past TYPE symsgno VALUE '019',

    "Flight Date
      c_flight_date_required TYPE symsgno VALUE '020',
      c_flight_date_past TYPE symsgno VALUE '021',
      c_flight_date_outside_travel TYPE symsgno VALUE '022',

    "Flight
      c_flight_not_found TYPE symsgno VALUE '023',

    "Supplement
      c_supplement_price_invalid TYPE symsgno VALUE '024',
      c_supplement_required  TYPE symsgno VALUE '025',
      c_supplement_not_found TYPE symsgno VALUE '026'.

ENDINTERFACE.
