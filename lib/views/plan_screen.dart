import 'package:master_plan/provider/plan_provider.dart';

import '../models/data_layer.dart';
import 'package:flutter/material.dart';

class PlanScreen extends StatefulWidget {
  final Plan plan;
  const PlanScreen({super.key, required this.plan});

  @override
  State createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  // Plan plan = const Plan();

  late ScrollController scrollController;
  Plan get plan => widget.plan;

  @override
  void initState() {
    super.initState();
    scrollController =
        ScrollController()..addListener(() {
          FocusScope.of(context).requestFocus(FocusNode());
        });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ValueNotifier<List<Plan>> plansNotifier = PlanProvider.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(plan.name)),
      body: ValueListenableBuilder<List<Plan>>(
        valueListenable: plansNotifier,
        builder: (context, plans, child) {
          Plan currentPlan = plans.firstWhere((p) => p.name == plan.name);
          return Column(
            children: [
              Expanded(child: _buildList(currentPlan)),
              SafeArea(child: Text(currentPlan.completenessMessage)),
            ],
          );
        },
      ),
      floatingActionButton: _buildAddTaskButton(context),
    );
  }

  Widget _buildTaskTile(Task task, int index, BuildContext context) {
    ValueNotifier<List<Plan>> planNotifier = PlanProvider.of(context);

    return ListTile(
      leading: Checkbox(
        value: task.complete,
        onChanged: (selected) {
          if (selected == null) return;

          // Get current plan and its index
          final currentPlan = planNotifier.value.firstWhere(
            (p) => p.name == plan.name,
            orElse: () => plan,
          );
          final planIndex = planNotifier.value.indexOf(currentPlan);

          // Create updated task list
          final updatedTasks = List<Task>.from(currentPlan.tasks);
          updatedTasks[index] = Task(
            description: task.description,
            complete: selected,
          );

          // Create updated plans list
          final updatedPlans = List<Plan>.from(planNotifier.value);
          updatedPlans[planIndex] = Plan(
            name: currentPlan.name,
            tasks: updatedTasks,
          );

          // Update state
          planNotifier.value = updatedPlans;
        },
      ),
      title: TextFormField(
        initialValue: task.description,
        onChanged: (text) {
          // Get current plan and its index
          final currentPlan = planNotifier.value.firstWhere(
            (p) => p.name == plan.name,
            orElse: () => plan,
          );
          final planIndex = planNotifier.value.indexOf(currentPlan);

          // Create updated task list
          final updatedTasks = List<Task>.from(currentPlan.tasks);
          updatedTasks[index] = Task(
            description: text,
            complete: task.complete,
          );

          // Create updated plans list
          final updatedPlans = List<Plan>.from(planNotifier.value);
          updatedPlans[planIndex] = Plan(
            name: currentPlan.name,
            tasks: updatedTasks,
          );

          // Update state
          planNotifier.value = updatedPlans;
        },
      ),
    );
  }

  Widget _buildAddTaskButton(BuildContext context) {
    ValueNotifier<List<Plan>> planNotifier = PlanProvider.of(context);

    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () {
        // Get current plan and its index
        final currentPlan = planNotifier.value.firstWhere(
          (p) => p.name == plan.name,
          orElse: () => plan,
        );
        final planIndex = planNotifier.value.indexOf(currentPlan);

        // Create updated task list
        final updatedTasks = List<Task>.from(currentPlan.tasks)
          ..add(const Task());

        // Create updated plans list
        final updatedPlans = List<Plan>.from(planNotifier.value);
        updatedPlans[planIndex] = Plan(
          name: currentPlan.name,
          tasks: updatedTasks,
        );

        // Update state
        planNotifier.value = updatedPlans;
      },
    );
  }

  Widget _buildList(Plan plan) {
    return ListView.builder(
      controller: scrollController,
      itemCount: plan.tasks.length,
      itemBuilder:
          (context, index) => _buildTaskTile(plan.tasks[index], index, context),
    );
  }
}
