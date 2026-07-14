import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../controllers/settings_controller.dart';
import '../../../controllers/skill_controller.dart';
import '../../../core/constants/category_dict.dart';
import '../../../core/constants/gamification_dict.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../core/models/category_model.dart';
import '../../../core/utils/color_extension.dart';
import '../../../core/utils/enum_types.dart';
import '../../../core/utils/global_messenger.dart';

class SkillTreeScreen extends StatefulWidget {
  const SkillTreeScreen({super.key});

  @override
  State<SkillTreeScreen> createState() => _SkillTreeScreenState();
}

class _SkillTreeScreenState extends State<SkillTreeScreen> {
  final GlobalKey _stackKey = GlobalKey();
  final Map<Enum?, GlobalKey> _nodeKeys = {};
  Map<Enum?, Offset> _nodePositions = {};
  Map<Enum?, double> _nodeRadii = {};
  final List<Enum?> _indexKey = [null];

  @override
  void initState() {
    super.initState();
    _nodeKeys[null] = GlobalKey();
    for (SectorType id in SectorType.values) {
      _nodeKeys[id] = GlobalKey();
      _indexKey.add(id);
    }
    for (SubSectorType id in SubSectorType.values) {
      _nodeKeys[id] = GlobalKey();
      _indexKey.add(id);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SkillController>().changeNode(null);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _calculateNodePositions(),
    );
  }

  void _calculateNodePositions() {
    if (!mounted) return;
    final RenderBox? stackBox =
        _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null) return;

    Map<Enum?, Offset> newPositions = {};
    Map<Enum?, double> newRadii = {};

    for (Enum? i in _indexKey) {
      final key = _nodeKeys[i];
      if (key != null && key.currentContext != null) {
        final RenderBox box =
            key.currentContext!.findRenderObject() as RenderBox;

        newPositions[i] = box.localToGlobal(
          box.size.center(Offset.zero),
          ancestor: stackBox,
        );

        newRadii[i] = box.size.width / 2;
      }
    }

    setState(() {
      _nodePositions = newPositions;
      _nodeRadii = newRadii;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<SettingsController>();
    final skillController = context.watch<SkillController>();
    final allocs = skillController.skillAllocations;
    final isRpg = settingsController.isRpgMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(GamificationDict.allocationTree.get(isRpg)),
        actions: [
          IconButton(
            onPressed: () async {
              await skillController.resetAllocation();
              GlobalMessenger.showMessage(
                context,
                message: UiDict.resetSkill,
                isSuccess: true,
              );
            },
            icon: FaIcon(
              FontAwesomeIcons.arrowRotateRight,
              size: 20,
              color: Colors.orangeAccent.adapt(context),
            ),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Stack(
              key: _stackKey,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: DynamicSkillTreePainter(
                      context: context,
                      positions: _nodePositions,
                      radii: _nodeRadii,
                      selectedId: skillController.selectedNode,
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      _buildNode(null, UiDict.income, 100, isRpg, isRoot: true),
                      const SizedBox(height: 100),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildNode(
                            SectorType.living,
                            GamificationDict.skillDaily,
                            allocs[SectorType.living],
                            isRpg,
                          ),
                          _buildNode(
                            SectorType.payDebt,
                            GamificationDict.skillDebt,
                            allocs[SectorType.payDebt],
                            isRpg,
                          ),
                          _buildNode(
                            SectorType.emergency,
                            GamificationDict.skillEmergency,
                            allocs[SectorType.emergency],
                            isRpg,
                          ),
                          _buildNode(
                            SectorType.investment,
                            GamificationDict.skillInvestment,
                            allocs[SectorType.investment],
                            isRpg,
                          ),
                        ],
                      ),
                      const SizedBox(height: 100),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildNode(
                              SubSectorType.essentials,
                              GamificationDict.skillRoutine,
                              allocs[SubSectorType.essentials],
                              isRpg,
                              size: 48,
                            ),
                            _buildNode(
                              SubSectorType.dreamFund,
                              GamificationDict.skillDream,
                              allocs[SubSectorType.dreamFund],
                              isRpg,
                              size: 48,
                            ),
                            _buildNode(
                              SubSectorType.lowRisk,
                              CategoryDict.lowRisk,
                              allocs[SubSectorType.lowRisk],
                              isRpg,
                              size: 48,
                            ),
                            _buildNode(
                              SubSectorType.mediumRisk,
                              CategoryDict.mediumRisk,
                              allocs[SubSectorType.mediumRisk],
                              isRpg,
                              size: 48,
                            ),
                            _buildNode(
                              SubSectorType.highRisk,
                              CategoryDict.highRisk,
                              allocs[SubSectorType.highRisk],
                              isRpg,
                              size: 48,
                            ),
                          ],
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,

                        height: skillController.selectedNode != null
                            ? 250
                            : 150,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (skillController.selectedNode != null) ...[
            _buildControlPanel(skillController, allocs),
          ],
        ],
      ),
    );
  }

  Widget _buildNode(
    Enum? id,
    CategoryModel data,
    double? percentage,
    bool isRpg, {
    bool isRoot = false,
    double size = 60,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedNode = context.read<SkillController>().selectedNode;
    bool isSelected = selectedNode == id;
    Color col = data.getColor(context);
    bool isLocked = percentage == null;
    return GestureDetector(
      onTap: () => context.read<SkillController>().changeNode(id),
      child: Column(
        children: [
          AnimatedContainer(
            key: _nodeKeys[id],
            duration: const Duration(milliseconds: 300),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isLocked
                  ? colorScheme.onPrimary
                  : (isSelected ? col : col.withOpacity(0.2)),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? colorScheme.onSurface
                    : (isLocked ? colorScheme.onSurfaceVariant : col),
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: col.withOpacity(0.6),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: FaIcon(
                isLocked ? FontAwesomeIcons.lock : data.icon(isRpg),
                color: isSelected
                    ? colorScheme.onSurface
                    : (isLocked ? colorScheme.onSurfaceVariant : col),
                size: size * 0.4,
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: size + 4,
            child: Text(
              data.get(isRpg),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: isSelected
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            percentage != null
                ? '${percentage.toInt().toString()}%'
                : '[LOCKED]',
            style: TextStyle(
              fontSize: 8,
              color: isSelected
                  ? colorScheme.onSurface
                  : colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.normal,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel(
    SkillController controller,
    Map<Enum, double?> allocs,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    final selectedNode = controller.selectedNode;
    final int? currentPercent = controller.currentPercentage?.toInt();

    final bool isRoot = selectedNode == null;
    final desc = controller.selectedNode != null
        ? GamificationDict.getSkillByEnum(
                controller.selectedNode!,
              ).description ??
              ''
        : '';
    bool isLocked = currentPercent == null;

    double minAllowed = 0.0;
    double maxAllowed = 100.0;
    bool canIncrease = false;
    bool canDecrease = false;

    int parentRegular = 0;
    int parentExtra = 0;

    if (!isRoot && !isLocked) {
      double basePoint = controller.baseAllocation[selectedNode] ?? 0.0;
      double limitPoint = controller.baseLimitAllocation[selectedNode] ?? 0.0;
      double current = currentPercent.toDouble();

      minAllowed = (limitPoint == 0.0) ? 0.0 : basePoint - limitPoint;
      maxAllowed = (limitPoint == 0.0) ? 100.0 : basePoint + limitPoint;

      canDecrease = current > minAllowed && current > 0.0;
      bool belowMax = current < maxAllowed && current < 100.0;

      if (selectedNode is SectorType) {
        canIncrease =
            (belowMax && controller.freeAllocation > 0) ||
            controller.extraFreeAllocation > 0;
      } else if (selectedNode is SubSectorType) {
        if (selectedNode == SubSectorType.lowRisk) {
          parentRegular =
              ((controller.freeAllocationLv1[SectorType.emergency] ?? 0.0) +
                      (controller.freeAllocationLv1[SectorType.investment] ??
                          0.0))
                  .toInt();
          parentExtra =
              ((controller.extraFreeAllocationLv1[SectorType.emergency] ??
                          0.0) +
                      (controller.extraFreeAllocationLv1[SectorType
                              .investment] ??
                          0.0))
                  .toInt();
        } else if (selectedNode == SubSectorType.essentials ||
            selectedNode == SubSectorType.dreamFund) {
          parentRegular =
              (controller.freeAllocationLv1[SectorType.living] ?? 0.0).toInt();
          parentExtra =
              (controller.extraFreeAllocationLv1[SectorType.living] ?? 0.0)
                  .toInt();
        } else {
          parentRegular =
              (controller.freeAllocationLv1[SectorType.investment] ?? 0.0)
                  .toInt();
          parentExtra =
              (controller.extraFreeAllocationLv1[SectorType.investment] ?? 0.0)
                  .toInt();
        }

        canIncrease =
            (belowMax && (parentRegular > 0 || parentExtra > 0)) ||
            (!belowMax && parentExtra > 0);
      }
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colorScheme.primary.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withOpacity(0.54),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (desc.isNotEmpty) ...[
              Text(
                desc,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                ),
              ),
              Divider(
                height: 24,
                color: colorScheme.onSurface.withOpacity(0.2),
              ),
            ],

            if (isLocked) ...[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.onSurface.withOpacity(0.1),
                  ),
                ),
                child: ListTile(
                  leading: FaIcon(
                    FontAwesomeIcons.lock,
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  title: Text(
                    GamificationDict.lockedSkill,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  subtitle: Text(
                    GamificationDict.lockedSkillDesc,
                    style: TextStyle(
                      fontSize: 10,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ] else ...[
              if (selectedNode is SectorType || selectedNode == null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      GamificationDict.skillPoint,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${controller.freeAllocation.toInt()}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.greenAccent.adapt(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      GamificationDict.skillExtraPoint,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${controller.extraFreeAllocation.toInt()}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.amber.adapt(context),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${GamificationDict.skillPoint}:',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${(selectedNode is SectorType) ? controller.freeAllocation.toInt() : parentRegular}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.greenAccent.adapt(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${GamificationDict.skillExtraPoint}:',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${(selectedNode is SectorType) ? controller.extraFreeAllocation.toInt() : parentExtra}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.amber.adapt(context),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle,

                      color: canDecrease
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant.withOpacity(0.7),
                      size: 32,
                    ),
                    onPressed: canDecrease
                        ? () => controller.decreaseAllocation()
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      isRoot ? '100%' : '$currentPercent%',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add_circle,

                      color: canIncrease
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant.withOpacity(0.7),
                      size: 32,
                    ),
                    onPressed: canIncrease
                        ? () => controller.increaseAllocation(context)
                        : null,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class DynamicSkillTreePainter extends CustomPainter {
  final BuildContext context;
  final Map<Enum?, Offset> positions;
  final Map<Enum?, double> radii;
  final Enum? selectedId;

  DynamicSkillTreePainter({
    required this.context,
    required this.positions,
    required this.radii,
    required this.selectedId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (positions.isEmpty || radii.isEmpty) return;
    final colorScheme = Theme.of(context).colorScheme;

    final paintNormal = Paint()
      ..color = colorScheme.onSurface.withOpacity(0.1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final paintHighlight = Paint()
      ..color = colorScheme.primary.withOpacity(0.8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    void drawConnection(Enum? parentId, Enum childId) {
      if (positions.containsKey(parentId) && positions.containsKey(childId)) {
        Offset parentCenter = positions[parentId]!;
        Offset childCenter = positions[childId]!;

        double parentRadius = radii[parentId] ?? 30.0;
        double childRadius = radii[childId] ?? 30.0;

        Offset startPoint = Offset(
          parentCenter.dx,
          parentCenter.dy + parentRadius,
        );

        Offset endPoint = Offset(childCenter.dx, childCenter.dy - childRadius);

        bool isHighlighted =
            (selectedId == parentId) || (selectedId == childId);

        canvas.drawLine(
          startPoint,
          endPoint,
          isHighlighted ? paintHighlight : paintNormal,
        );
      }
    }

    drawConnection(null, SectorType.living);
    drawConnection(null, SectorType.payDebt);
    drawConnection(null, SectorType.emergency);
    drawConnection(null, SectorType.investment);

    drawConnection(SectorType.living, SubSectorType.essentials);
    drawConnection(SectorType.living, SubSectorType.dreamFund);

    drawConnection(SectorType.emergency, SubSectorType.lowRisk);
    drawConnection(SectorType.investment, SubSectorType.lowRisk);
    drawConnection(SectorType.investment, SubSectorType.mediumRisk);
    drawConnection(SectorType.investment, SubSectorType.highRisk);
  }

  bool drawConnection = false;

  @override
  bool shouldRepaint(covariant DynamicSkillTreePainter oldDelegate) {
    return oldDelegate.selectedId != selectedId ||
        oldDelegate.positions != positions;
  }
}
