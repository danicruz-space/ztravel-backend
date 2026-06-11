@Metadata.allowExtensions: true
@Search.searchable: true

define root view entity Z_C_TRAVEL provider contract transactional_query as projection on Z_I_TRAVEL
{
    @Search.defaultSearchElement: true
    key TravelId,

    @ObjectModel.text.element: ['AgencyName']
    @Consumption.valueHelpDefinition: [{ entity: { name: 'Z_I_AGENCY_VH', element: 'AgencyId' } }]
    AgencyId,
    _Agency.Name as AgencyName,

    @ObjectModel.text.element: ['FirstName']
    @Consumption.valueHelpDefinition: [{ entity: { name: 'Z_I_CUSTOMER_VH', element: 'CustomerId' } }]
    CustomerId,
    _Customer.FirstName as FirstName,

    BeginDate,
    EndDate,
    BookingFee,
    TotalPrice,

    @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Currency', element: 'Currency' } }]
    CurrencyCode,
    Description,

    @ObjectModel.text.element: ['StatusText']
    @Consumption.valueHelpDefinition: [{ entity: { name: 'Z_I_STATUS_VH', element: 'StatusValue' } }]
    Status,

    _StatusVH.Description as StatusText,
    _StatusVH.StatusCriticality as StatusCriticality,
    
    
    @Semantics.largeObject: { mimeType: 'AgencyMimeType', fileName: 'AgencyFilename', contentDispositionPreference: #INLINE }
    _Agency.Attachment as AgencyAttachment,
    
    @Semantics.mimeType: true
    _Agency.MimeType   as AgencyMimeType,
    
    _Agency.Filename   as AgencyFilename,
        
    LastChangedAt,
    CreatedBy,
    CreatedAt,
    LastChangedBy,

    _Agency,
    _Customer,
    _Currency,
    _StatusVH,
    _Booking : redirected to composition child Z_C_BOOKING
}
