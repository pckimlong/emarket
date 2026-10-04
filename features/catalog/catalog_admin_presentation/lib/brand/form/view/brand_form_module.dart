import 'package:admin_ui_kit/admin_ui_kit.dart';
import 'package:catalog_admin_presentation/brand/form/bloc/brand_form_bloc.dart';
import 'package:catalog_admin_presentation/brand/form/bloc/brand_form_event.dart';
import 'package:catalog_admin_presentation/brand/form/bloc/brand_form_state.dart';
import 'package:catalog_domain/catalog_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_admin_presentation/media_admin_presentation.dart';
import 'package:presentation_utils/presentation_utils.dart';

class BrandFormModule extends StatelessWidget {
  const BrandFormModule({
    super.key,
    required this.brandRepo,
    this.brandId,
    this.onSaved,
  });

  final IAdminBrandRepo brandRepo;
  final BrandId? brandId;
  final ValueChanged<Brand>? onSaved;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BrandFormBloc(
        brandRepo: brandRepo,
        brandId: brandId,
      ),
      child: _BrandFormView(onSaved: onSaved),
    );
  }
}

class _BrandFormView extends StatefulWidget {
  const _BrandFormView({this.onSaved});

  final ValueChanged<Brand>? onSaved;

  @override
  State<_BrandFormView> createState() => _BrandFormViewState();
}

class _BrandFormViewState extends State<_BrandFormView> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BrandFormBloc, BrandFormState>(
      listenWhen: (prev, curr) =>
          prev.submissionStatus != curr.submissionStatus,
      listener: (context, state) {
        state.submissionStatus.toNullable()?.whenOrNull(
          data: (brand) => widget.onSaved?.call(brand),
        );
      },
      builder: (context, state) {
        if (_nameController.text != state.name &&
            !state.isSubmitting &&
            state.name.isNotEmpty &&
            _nameController.text.isEmpty) {
          _nameController.text = state.name;
        }

        final initialLoading =
            state.initialFetchStatus.toNullable()?.isLoading ?? false;
        if (initialLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final initialError = state.initialFetchStatus.toNullable();
        if (initialError is AsyncFailureState<Brand>) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(initialError.failure.displayMessage),
                const SizedBox(height: 12),
                FButton(
                  onPress: () => context.read<BrandFormBloc>().add(
                    const BrandFormStarted(),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final nameError = state.hasAttemptedSubmit && state.nameFailure != null
            ? switch (state.nameFailure!) {
                BrandInputFailure.nameRequired => 'Brand name is required',
                BrandInputFailure.nameTooShort =>
                  'Name must be at least 2 characters',
                BrandInputFailure.nameTooLong =>
                  'Name must be at most 100 characters',
                _ => null,
              }
            : null;

        final logoError = state.hasAttemptedSubmit && state.logoFailure != null
            ? switch (state.logoFailure!) {
                BrandInputFailure.logoPathRequired =>
                  'Please upload a brand logo',
                BrandInputFailure.logoPathInvalid => 'Invalid logo file format',
                _ => null,
              }
            : null;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.isEditing ? 'Edit Brand' : 'Create Brand',
                style: context.theme.typography.display.sm.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              FTextField(
                control: FTextFieldControl.managed(
                  controller: _nameController,
                  onChange: (value) => context.read<BrandFormBloc>().add(
                    BrandFormNameChanged(value.text),
                  ),
                ),
                label: const Text('Brand Name'),
                hint: 'e.g. Nike, Adidas',
                enabled: state.canEdit,
                error: nameError != null ? Text(nameError) : null,
              ),
              const SizedBox(height: 20),
              AppMediaPicker(
                label: 'Brand Logo',
                folder: 'brands',
                initialPreviewUri: state.logoUri,
                enabled: state.canEdit,
                onMediaChanged: (media) {
                  context.read<BrandFormBloc>().add(
                    BrandFormLogoChanged(media?.path, media?.publicUri),
                  );
                },
              ),
              if (logoError != null) ...[
                const SizedBox(height: 6),
                Text(
                  logoError,
                  style: context.theme.typography.body.xs.copyWith(
                    color: context.theme.colors.destructive,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              FSwitch(
                label: const Text('Active status'),
                value: state.isActive,
                onChange: state.canEdit
                    ? (val) => context.read<BrandFormBloc>().add(
                        BrandFormIsActiveChanged(val),
                      )
                    : null,
              ),
              const SizedBox(height: 32),
              FButton(
                onPress: state.canEdit
                    ? () => context.read<BrandFormBloc>().add(
                        const BrandFormSubmitted(),
                      )
                    : null,
                child: state.isSubmitting
                    ? const Text('Saving...')
                    : Text(state.isEditing ? 'Save Changes' : 'Create Brand'),
              ),
              if (state.submissionStatus.toNullable()
                  is AsyncFailureState<Brand>) ...[
                const SizedBox(height: 16),
                Text(
                  (state.submissionStatus.toNullable()!
                          as AsyncFailureState<Brand>)
                      .failure
                      .displayMessage,
                  style: context.theme.typography.body.sm.copyWith(
                    color: context.theme.colors.destructive,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
