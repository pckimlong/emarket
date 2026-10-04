sealed class const BrandFormEvent();
final class const BrandFormStarted() extends BrandFormEvent;
final class const BrandFormNameChanged(final String name)
    extends BrandFormEvent;
final class const BrandFormLogoChanged(
  final String? logoPath,
  final Uri? previewUri,
) extends BrandFormEvent;
final class const BrandFormLogoUriChanged(final String logoUri)
    extends BrandFormEvent;
final class const BrandFormIsActiveChanged(final bool isActive)
    extends BrandFormEvent;
final class const BrandFormSubmitted() extends BrandFormEvent;
