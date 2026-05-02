import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../controllers/skill_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/profile_dict.dart';
import '../../../core/constants/skill_dict.dart';
import '../../../core/models/category_model.dart';
import '../../../models/allocation_model.dart';

class SkillTree extends StatefulWidget {
  const SkillTree({super.key});

  @override
  State<SkillTree> createState() => _SkillTreeState();
}

class _SkillTreeState extends State<SkillTree> {
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
    final skillController = context.watch<SkillController>();
    final allocs = skillController.skillAllocations;
    final isRpg = skillController.isRpg;

    return Scaffold(
      appBar: AppBar(
        title: Text(ProfileDict.allocationTree.get(isRpg)),
        actions: [
          IconButton(
            onPressed: () => skillController.resetAllocation(),
            icon: const FaIcon(
              FontAwesomeIcons.arrowRotateRight,
              size: 20,
              color: Colors.orangeAccent,
            ),
            tooltip: 'Reset to Default',
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
                      _buildNode(
                        null,
                        SkillDict.income,
                        100,
                        isRpg,
                        isRoot: true,
                      ),
                      const SizedBox(height: 100),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildNode(
                            SectorType.living,
                            SkillDict.dailyParent,
                            allocs[SectorType.living],
                            isRpg,
                          ),
                          _buildNode(
                            SectorType.payDebt,
                            SkillDict.debt,
                            allocs[SectorType.payDebt],
                            isRpg,
                          ),
                          _buildNode(
                            SectorType.emergency,
                            SkillDict.emergency,
                            allocs[SectorType.emergency],
                            isRpg,
                          ),
                          _buildNode(
                            SectorType.investment,
                            SkillDict.investment,
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
                              SkillDict.dailyRoutine,
                              allocs[SubSectorType.essentials],
                              isRpg,
                              size: 48,
                            ),
                            _buildNode(
                              SubSectorType.dreamFund,
                              SkillDict.dreamFund,
                              allocs[SubSectorType.dreamFund],
                              isRpg,
                              size: 48,
                            ),
                            _buildNode(
                              SubSectorType.lowRisk,
                              SkillDict.lowRisk,
                              allocs[SubSectorType.lowRisk],
                              isRpg,
                              size: 48,
                            ),
                            _buildNode(
                              SubSectorType.mediumRisk,
                              SkillDict.mediumRisk,
                              allocs[SubSectorType.mediumRisk],
                              isRpg,
                              size: 48,
                            ),
                            _buildNode(
                              SubSectorType.highRisk,
                              SkillDict.highRisk,
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
    final selectedNode = context.read<SkillController>().selectedNode;
    bool isSelected = selectedNode == id;
    Color col = data.color ?? Colors.black;
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
                  ? Colors.black
                  : (isSelected ? col : col.withOpacity(0.2)),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Colors.white
                    : (isLocked ? Colors.grey : col),
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
                    ? Colors.white
                    : (isLocked ? Colors.grey : col),
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
                color: isSelected ? Colors.white : Colors.grey,
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
              color: isSelected ? Colors.white : Colors.grey,
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
    final selectedNode = controller.selectedNode;
    final int? currentPercent = controller.currentPercentage?.toInt();

    final bool isRoot = selectedNode == null;
    final desc = controller.selectedNode != null
        ? SkillDict.getByEnum(controller.selectedNode!).description ?? ''
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
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary.withOpacity(0.5)),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (desc.isNotEmpty) ...[
              Text(
                desc,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade300),
              ),
              const Divider(height: 24, color: Colors.white24),
            ],

            if (isLocked) ...[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: ListTile(
                  leading: const FaIcon(
                    FontAwesomeIcons.lock,
                    color: Colors.grey,
                    size: 20,
                  ),
                  title: const Text(
                    'Skill Locked',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  subtitle: Text(
                    'This category will unlock automatically as you progress.',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                ),
              ),
            ] else ...[
              if (selectedNode is SectorType || selectedNode == null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Regular Free Pts:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${controller.freeAllocation.toInt()}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.greenAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Extra Free Pts:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${controller.extraFreeAllocation.toInt()}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      (selectedNode is SectorType)
                          ? 'Regular Free Pts:'
                          : 'Regular Parent Pts:',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${(selectedNode is SectorType) ? controller.freeAllocation.toInt() : parentRegular}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.greenAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      (selectedNode is SectorType)
                          ? 'Extra Free Pts:'
                          : 'Extra Parent Pts:',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${(selectedNode is SectorType) ? controller.extraFreeAllocation.toInt() : parentExtra}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.amber,
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
                          ? AppColors.primary
                          : Colors.grey.shade700,
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
                          ? AppColors.primary
                          : Colors.grey.shade700,
                      size: 32,
                    ),
                    onPressed: canIncrease
                        ? () => controller.increaseAllocation()
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
  final Map<Enum?, Offset> positions;
  final Map<Enum?, double> radii;
  final Enum? selectedId;

  DynamicSkillTreePainter({
    required this.positions,
    required this.radii,
    required this.selectedId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (positions.isEmpty || radii.isEmpty) return;

    final paintNormal = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final paintHighlight = Paint()
      ..color = AppColors.primary.withOpacity(0.8)
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
