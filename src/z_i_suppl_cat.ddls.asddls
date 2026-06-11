@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Catálogo de Suplementos'
@Metadata.ignorePropagatedAnnotations: true

define view entity Z_I_SUPPL_CAT as select from /dmo/supplement as Suppl
left outer join /dmo/suppl_text as Text on Text.supplement_id = Suppl.supplement_id and Text.language_code = $session.system_language
association [0..1] to zsuppl as _Photo on $projection.SupplementId = _Photo.supplement_id
{
  key Suppl.supplement_id                                as SupplementId,

      Text.description                                   as Description,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      Suppl.price                                        as Price,
      Suppl.currency_code                                as CurrencyCode,

      @Semantics.largeObject: { mimeType: 'MimeType',
                                fileName: 'Filename',
                                contentDispositionPreference: #INLINE }
      @Semantics.imageUrl: true
      _Photo.attachment                                  as Attachment,

      @Semantics.mimeType: true
      _Photo.mime_type                                   as MimeType,

      _Photo.filename                                    as Filename,

      _Photo
}
