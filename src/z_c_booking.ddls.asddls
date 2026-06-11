@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS de consumo para Booking'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity Z_C_BOOKING 
  as projection on Z_I_BOOKING
{
  key TravelId,
  key BookingId,
      BookingDate,
      @ObjectModel.text.element: ['FirstName']
      @Consumption.valueHelpDefinition: [{ entity: { name: 'Z_I_CUSTOMER_VH', element: 'CustomerId' } }]
      CustomerId,
      _Customer.FirstName as FirstName,
      
      @ObjectModel.text.element: ['CarrierName']
      @Consumption.valueHelpDefinition: [{ entity: { name: 'Z_I_CARRIER_VH', element: 'CarrierId' } }]
      CarrierId,
      _Carrier.Name as CarrierName,
      
      @ObjectModel.text.element: ['DepartureAirport']
      @Consumption.valueHelpDefinition: [{ entity: { name: 'Z_I_CONNECTION_VH', element: 'ConnectionId' } }]
      ConnectionId,
      _ConnectionFuzzy.DepartureAirport as DepartureAirport,
      
      FlightDate,
      
      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice,

      CurrencyCode,
      
      @Semantics.amount.currencyCode: 'CurrencyCode'
      _Totals.TotalSupplementPrice as TotalSupplementPrice,
      
      _Travel : redirected to parent Z_C_TRAVEL,
      _BookSupplement : redirected to composition child Z_C_BOOKSUPPLEMENT,
      _Connection,
      _ConnectionFuzzy,
      _Customer,
      _Totals
}
