import 'package:fintale/core/theme/mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/profile_dict.dart';
import '../../../core/constants/skill_dict.dart';
import '../../../core/dummy/dummy_data.dart';
import '../../../core/models/category_model.dart';
import '../../../models/allocation_model.dart';
import '../../../models/user_model.dart';

class SkillTree extends StatefulWidget {
  const SkillTree({super.key});

  @override
  State<SkillTree> createState() => _SkillTreeState();
}

class _SkillTreeState extends State<SkillTree> {
  int _selectedNode = 1;
  final UserModel userData = DummyData.user;
  final GlobalKey _stackKey = GlobalKey();
  final Map<int, GlobalKey> _nodeKeys = {};
  Map<int, Offset> _nodePositions = {};
  Map<int, double> _nodeRadii = {};

  @override
  void initState() {
    super.initState();
    for (int i = 1; i <= 10; i++) {
      _nodeKeys[i] = GlobalKey();
    }
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _calculateNodePositions(),
    );
  }

  void _calculateNodePositions() {
    if (!mounted) return;
    final RenderBox? stackBox =
        _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null) return;

    Map<int, Offset> newPositions = {};
    Map<int, double> newRadii = {};

    for (int i = 1; i <= 10; i++) {
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
    final isRpg = Provider.of<ModeProvider>(context).isRpgMode;
    return Scaffold(
      appBar: AppBar(title: Text(ProfileDict.allocationTree.get(isRpg))),
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
                      selectedId: _selectedNode,
                    ),
                  ),
                ),

                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      _buildNode(1, SkillDict.income, 100, isRpg, isRoot: true),
                      const SizedBox(height: 100),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildNode(
                            2,
                            SkillDict.dailyParent,
                            userData.skillAllocations[SectorType.living] ?? 0.0,
                            isRpg,
                          ),
                          _buildNode(
                            3,
                            SkillDict.debt,
                            userData.skillAllocations[SectorType.payDebt] ??
                                0.0,
                            isRpg,
                          ),
                          _buildNode(
                            4,
                            SkillDict.emergency,
                            userData.skillAllocations[SectorType.emergency] ??
                                0.0,
                            isRpg,
                          ),
                          _buildNode(
                            5,
                            SkillDict.investment,
                            userData.skillAllocations[SectorType.investment] ??
                                0.0,
                            isRpg,
                            isLocked: true,
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
                              6,
                              SkillDict.dailyRoutine,
                              userData.skillAllocations[SubSectorType
                                      .essentials] ??
                                  0.0,
                              isRpg,
                              size: 48,
                            ),
                            _buildNode(
                              7,
                              SkillDict.dreamFund,
                              userData.skillAllocations[SubSectorType
                                      .dreamFund] ??
                                  0.0,
                              isRpg,
                              size: 48,
                            ),
                            _buildNode(
                              8,
                              SkillDict.lowRisk,
                              userData.skillAllocations[SubSectorType
                                      .lowRisk] ??
                                  0.0,
                              isRpg,
                              size: 48,
                            ),
                            _buildNode(
                              9,
                              SkillDict.mediumRisk,
                              userData.skillAllocations[SubSectorType
                                      .mediumRisk] ??
                                  0.0,
                              isRpg,
                              size: 48,
                              isLocked: true,
                            ),
                            _buildNode(
                              10,
                              SkillDict.highRisk,
                              userData.skillAllocations[SubSectorType
                                      .highRisk] ??
                                  0.0,
                              isRpg,
                              size: 48,
                              isLocked: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 150),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (_selectedNode != 1) _buildControlPanel(),
        ],
      ),
    );
  }

  Widget _buildNode(
    int id,
    CategoryModel data,
    double percentage,
    bool isRpg, {
    bool isRoot = false,
    bool isLocked = false,
    double size = 60,
  }) {
    bool isSelected = _selectedNode == id;
    Color col = data.color ?? Colors.black;
    return GestureDetector(
      onTap: () => setState(() => _selectedNode = id),
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
          Text(
            data.get(isRpg),
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? Colors.white : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '${percentage.toInt().toString()}%',
            style: TextStyle(
              fontSize: 8,
              color: isSelected ? Colors.white : Colors.grey,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary.withOpacity(0.5)),
          boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Adjust Stat Points',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.remove_circle,
                    color: AppColors.primary,
                  ),
                  onPressed: () {},
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '30%',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppColors.primary),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DynamicSkillTreePainter extends CustomPainter {
  final Map<int, Offset> positions;
  final Map<int, double> radii;
  final int selectedId;

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

    void drawConnection(int parentId, int childId) {
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

        bool isHighlighted = (selectedId == parentId);

        canvas.drawLine(
          startPoint,
          endPoint,
          isHighlighted ? paintHighlight : paintNormal,
        );
      }
    }

    drawConnection(1, 2);
    drawConnection(1, 3);
    drawConnection(1, 4);
    drawConnection(1, 5);

    drawConnection(2, 6);
    drawConnection(2, 7);

    drawConnection(4, 8);
    drawConnection(5, 8);

    drawConnection(5, 9);
    drawConnection(5, 10);
  }

  @override
  bool shouldRepaint(covariant DynamicSkillTreePainter oldDelegate) {
    return oldDelegate.selectedId != selectedId ||
        oldDelegate.positions != positions;
  }
}
