 @AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BookingSupplement por Booking'
@Metadata.ignorePropagatedAnnotations: true
define view entity Z_I_BOOKSUPPLEMENT as select from /dmo/book_suppl
association to parent Z_I_BOOKING as _Booking on  $projection.TravelId = _Booking.TravelId and $projection.BookingId = _Booking.BookingId
association [1..1] to Z_I_TRAVEL as _Travel on $projection.TravelId = _Travel.TravelId
association [0..1] to /dmo/suppl_text as _SupplementText on $projection.SupplementId = _SupplementText.supplement_id
association [0..1] to zsuppl as _Supp on $projection.SupplementId = _Supp.supplement_id
{
  key travel_id             as TravelId,
  key booking_id            as BookingId,
  key booking_supplement_id as BookingSupplementId,
      supplement_id         as SupplementId,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      price                 as Price,
      currency_code         as CurrencyCode,

      _Booking,
      _Travel,
      _SupplementText,
      _Supp
}
