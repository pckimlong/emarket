import 'package:admin_ui_kit/admin_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_domain/media_domain.dart';

import '../cubit/media_upload_cubit.dart';
import '../cubit/media_upload_state.dart';
import '../services/media_file_picker.dart';

class AppMediaPicker extends StatefulWidget {
  const AppMediaPicker({
    super.key,
    required this.folder,
    this.initialPreviewUri,
    this.onMediaChanged,
    this.filePicker,
    this.enabled = true,
    this.label = 'Image',
  });

  final String folder;
  final Uri? initialPreviewUri;
  final ValueChanged<UploadedMedia?>? onMediaChanged;
  final IMediaFilePicker? filePicker;
  final bool enabled;
  final String label;

  @override
  State<AppMediaPicker> createState() => _AppMediaPickerState();
}

class _AppMediaPickerState extends State<AppMediaPicker> {
  Uri? _currentPreviewUri;
  bool _removed = false;

  @override
  void initState() {
    super.initState();
    _currentPreviewUri = widget.initialPreviewUri;
  }

  @override
  void didUpdateWidget(covariant AppMediaPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPreviewUri != widget.initialPreviewUri && !_removed) {
      _currentPreviewUri = widget.initialPreviewUri;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaRepo = context.read<IMediaRepo>();

    return BlocProvider(
      create: (_) => MediaUploadCubit(
        mediaRepo: mediaRepo,
        filePicker: widget.filePicker,
      ),
      child: BlocConsumer<MediaUploadCubit, MediaUploadState>(
        listener: (context, state) {
          state.whenOrNull(
            success: (media) {
              setState(() {
                _currentPreviewUri = media.publicUri;
                _removed = false;
              });
              widget.onMediaChanged?.call(media);
            },
          );
        },
        builder: (context, state) {
          final cubit = context.read<MediaUploadCubit>();
          final isUploading = state.maybeWhen(
            uploading: (_) => true,
            orElse: () => false,
          );
          final failure = state.maybeWhen(
            failure: (f) => f,
            orElse: () => null,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.label.isNotEmpty) ...[
                Text(
                  widget.label,
                  style: context.theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (isUploading)
                _buildUploadingView(context)
              else if (_currentPreviewUri != null && !_removed)
                _buildPreviewView(context, cubit, _currentPreviewUri!)
              else
                _buildUploadButton(context, cubit),
              if (failure != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      LucideIcons.circle_alert,
                      size: 14,
                      color: context.theme.colors.destructive,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        failure.displayMessage,
                        style: context.theme.typography.body.xs.copyWith(
                          color: context.theme.colors.destructive,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildUploadingView(BuildContext context) {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        color: context.theme.colors.secondary,
        borderRadius: context.theme.style.borderRadius.md,
        border: Border.all(
          color: context.theme.colors.border,
          width: context.theme.style.borderWidth,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(height: 8),
            Text('Uploading...', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton(BuildContext context, MediaUploadCubit cubit) {
    return FTappable(
      onPress: widget.enabled
          ? () => cubit.pickAndUpload(folder: widget.folder)
          : null,
      builder: (_, _, _) => Container(
        width: 140,
        height: 120,
        decoration: BoxDecoration(
          color: context.theme.colors.secondary,
          borderRadius: context.theme.style.borderRadius.md,
          border: Border.all(
            color: context.theme.colors.border,
            width: context.theme.style.borderWidth,
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.upload,
                size: 24,
                color: context.theme.colors.mutedForeground,
              ),
              const SizedBox(height: 6),
              Text(
                'Upload image',
                style: context.theme.typography.body.xs.copyWith(
                  fontWeight: FontWeight.w500,
                  color: context.theme.colors.foreground,
                ),
              ),
              Text(
                'PNG, WEBP, JPG',
                style: context.theme.typography.body.xs.copyWith(
                  fontSize: 10,
                  color: context.theme.colors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewView(
    BuildContext context,
    MediaUploadCubit cubit,
    Uri previewUri,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            borderRadius: context.theme.style.borderRadius.md,
            border: Border.all(
              color: context.theme.colors.border,
              width: context.theme.style.borderWidth,
            ),
            color: context.theme.colors.secondary,
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.network(
            previewUri.toString(),
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Center(
              child: Icon(
                LucideIcons.image,
                size: 28,
                color: context.theme.colors.mutedForeground,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FButton(
              variant: .secondary,
              onPress: widget.enabled
                  ? () => cubit.pickAndUpload(folder: widget.folder)
                  : null,
              child: const Text('Change'),
            ),
            const SizedBox(height: 8),
            FButton(
              variant: .destructive,
              onPress: widget.enabled
                  ? () {
                      setState(() {
                        _currentPreviewUri = null;
                        _removed = true;
                      });
                      cubit.reset();
                      widget.onMediaChanged?.call(null);
                    }
                  : null,
              child: const Text('Remove'),
            ),
          ],
        ),
      ],
    );
  }
}
