@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking/s respetivo de cada Travel'
@Metadata.ignorePropagatedAnnotations: true
define view entity Z_I_BOOKING as select from /dmo/booking as Booking
association [0..1] to /DMO/I_Customer as _Customer on $projection.CustomerId = _Customer.CustomerID
association [0..1] to /DMO/I_Connection as _ConnectionFuzzy on $projection.ConnectionId = _ConnectionFuzzy.ConnectionID
association [0..1] to /DMO/I_Carrier as _Carrier on $projection.CarrierId = _Carrier.AirlineID
association to parent Z_I_TRAVEL as _Travel on $projection.TravelId = _Travel.TravelId
association [0..1] to Z_I_BOOKSUPPL_TOTAL as _Totals on $projection.TravelId = _Totals.TravelId and $projection.BookingId = _Totals.BookingId
association [0..1] to Z_I_CONN_GEO as _Connection on  $projection.CarrierId = _Connection.CarrierId and $projection.ConnectionId = _Connection.ConnectionId
  composition [0..*] of Z_I_BOOKSUPPLEMENT as _BookSupplement
{
  key travel_id     as TravelId,
  key booking_id    as BookingId,
      booking_date  as BookingDate,
      customer_id   as CustomerId,
      carrier_id    as CarrierId,
      connection_id as ConnectionId,
      flight_date   as FlightDate,
      
      @Semantics.amount.currencyCode: 'CurrencyCode'
      flight_price  as FlightPrice,
      currency_code as CurrencyCode,
      
      _Travel,
      _BookSupplement,
      _Connection,
      _Customer,
      _Carrier,
      _ConnectionFuzzy,
      _Totals
}
