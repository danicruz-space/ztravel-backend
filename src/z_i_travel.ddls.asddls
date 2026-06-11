@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel Root View Entity'

define root view entity Z_I_TRAVEL as select from /dmo/travel
  association [0..1] to /DMO/I_Agency   as _Agency   on $projection.AgencyId = _Agency.AgencyID
  association [0..1] to /DMO/I_Customer as _Customer on $projection.CustomerId = _Customer.CustomerID
  association [0..1] to I_Currency      as _Currency on $projection.CurrencyCode = _Currency.Currency
  association [0..1] to Z_I_STATUS_VH as _StatusVH on $projection.Status = _StatusVH.StatusValue
  composition [0..*] of Z_I_BOOKING     as _Booking
{
  @EndUserText.label: 'ID da Viagem'
  key travel_id       as TravelId,

  @EndUserText.label: 'Agência'
  agency_id           as AgencyId,

  @EndUserText.label: 'Cliente'
  customer_id         as CustomerId,

  @EndUserText.label: 'Data de Início'
  begin_date          as BeginDate,

  @EndUserText.label: 'Data de Fim'
  end_date            as EndDate,
  
  @Semantics.amount.currencyCode: 'CurrencyCode'
  @EndUserText.label: 'Taxa de Reserva'
  booking_fee         as BookingFee,

  @Semantics.amount.currencyCode: 'CurrencyCode'
  @EndUserText.label: 'Preço Total'
  total_price         as TotalPrice,

  @EndUserText.label: 'Moeda'
  currency_code       as CurrencyCode,

  @EndUserText.label: 'Descrição'
  description         as Description,
  
  @ObjectModel.text.association: '_StatusVH'
  @EndUserText.label: 'Estado'
  status              as Status,
  
  @Semantics.user.createdBy: true
  createdby           as CreatedBy,

  @Semantics.systemDateTime.createdAt: true
  createdat           as CreatedAt,

  @Semantics.user.lastChangedBy: true
  lastchangedby       as LastChangedBy,

  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  lastchangedat       as LastChangedAt,

  _Agency,
  _Customer,
  _Currency,
  _StatusVH,
  _Booking
}
