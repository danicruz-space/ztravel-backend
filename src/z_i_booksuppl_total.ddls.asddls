@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Total de suplementos por Booking'
@Metadata.ignorePropagatedAnnotations: true
define view entity Z_I_BOOKSUPPL_TOTAL as select from /dmo/book_suppl
{
    key travel_id as TravelId,
    key booking_id as BookingId,

    @Semantics.amount.currencyCode: 'CurrencyCode'
    sum( price ) as TotalSupplementPrice,
    currency_code as CurrencyCode
}
group by travel_id, booking_id, currency_code
