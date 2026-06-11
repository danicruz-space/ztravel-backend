@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS de consumo para BookingSupplement'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity Z_C_BOOKSUPPLEMENT as projection on Z_I_BOOKSUPPLEMENT
{
  key TravelId,
  key BookingId,
  key BookingSupplementId,

  @ObjectModel.text.element: ['SupplementDescription']
  @Consumption.valueHelpDefinition: [{ entity: { name: 'Z_I_BOOKSUPP_VH', element: 'SupplementId' } }]
  SupplementId,
  _SupplementText.description as SupplementDescription,

  @Semantics.amount.currencyCode: 'CurrencyCode'
  Price,

  _Booking.CurrencyCode as CurrencyCode,


  _Supp.filename as SupplementFilename,
  @Semantics.mimeType: true
  _Supp.mime_type as SupplementMimeType,
  @Semantics.largeObject: { mimeType: 'SupplementMimeType', fileName: 'SupplementFilename', contentDispositionPreference: #INLINE }
  @Semantics.imageUrl: true
  _Supp.attachment as SupplementAttachment,

  _Booking : redirected to parent Z_C_BOOKING,
  _Travel  : redirected to Z_C_TRAVEL,
  _SupplementText,
  _Supp
}
