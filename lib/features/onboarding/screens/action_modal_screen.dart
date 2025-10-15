import 'package:faithlock/features/onboarding/models/interactive_action_model.dart';
import 'package:faithlock/features/onboarding/widgets/interactive_action_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Clean, minimal action modal - focus sur l'essentiel
class CleanActionModalScreen extends StatefulWidget {
  final List<InteractiveAction> actions;
  final String stepTitle;
  final bool canSkip;
  final Function(List<ActionResult>) onActionsCompleted;
  final VoidCallback? onSkip;

  const CleanActionModalScreen({
    super.key,
    required this.actions,
    required this.stepTitle,
    required this.canSkip,
    required this.onActionsCompleted,
    this.onSkip,
  });

  @override
  State<CleanActionModalScreen> createState() => _CleanActionModalScreenState();
}

class _CleanActionModalScreenState extends State<CleanActionModalScreen> {
  final Map<String, ActionResult> _actionResults = {};

  bool get _canComplete {
    final requiredActions = widget.actions.where((action) => action.isRequired);
    return requiredActions.every((action) {
      final result = _actionResults[action.id];
      return result != null && result.isCompleted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fixed header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              widget.stepTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),

                  ...widget.actions.map((action) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: InteractiveActionWidget(
                          action: action,
                          isIOS: GetPlatform.isIOS,
                          onActionCompleted: _handleActionCompleted,
                        ),
                      )),
                ],
              ),
            ),
          ),

          // Fixed bottom buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _canComplete ? _handleComplete : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _canComplete ? Colors.black87 : Colors.grey[300],
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _canComplete ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  ),
                ),

                // Skip button si permis
                if (widget.canSkip) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      widget.onSkip?.call();
                    },
                    child: Text(
                      'Skip for now',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],

                // Safe area
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleActionCompleted(ActionResult result) {
    setState(() {
      _actionResults[result.actionId] = result;
    });
    HapticFeedback.lightImpact();
  }

  void _handleComplete() {
    HapticFeedback.mediumImpact();
    widget.onActionsCompleted(_actionResults.values.toList());
  }
}
