@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value help para Status de Booking'
@ObjectModel.dataCategory: #TEXT
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
define view entity Z_I_STATUS_VH as select from dd07t
{
    @ObjectModel.text.element: [ 'Description' ]
    @UI.textArrangement: #TEXT_ONLY
    key cast( domvalue_l as zde_disponivel ) as StatusValue,
    
    @Semantics.text: true
    @Search.defaultSearchElement: true
    @Search.fuzzinessThreshold: 0.8
    ddtext as Description,
    
    case domvalue_l
        when 'N' then 5
        when 'P' then 2
        when 'B' then 3
        when 'X' then 1 
    end as StatusCriticality
} where domname = '/DMO/STATUS' and ddlanguage = 'E' and as4local = 'A'
