// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Nexo';

  @override
  String get inbox => '收件箱';

  @override
  String get today => '今天';

  @override
  String get upcoming => '即将到来';

  @override
  String get labels => '标签';

  @override
  String get todos => '待办';

  @override
  String get newTodo => '新建';

  @override
  String get openWidgetWindow => '打开便签窗口';

  @override
  String get searchHint => '搜索…';

  @override
  String get filterOpen => '未完成';

  @override
  String get filterCompleted => '已完成';

  @override
  String get filterDueToday => '今日到期';

  @override
  String get filterOverdue => '已逾期';

  @override
  String get priorityAny => '优先级：不限';

  @override
  String get priorityLow => '低';

  @override
  String get priorityNormal => '普通';

  @override
  String get priorityHigh => '高';

  @override
  String get priorityUrgent => '紧急';

  @override
  String get noTodosYet => '还没有待办。先创建一个吧。';

  @override
  String get details => '详情';

  @override
  String get selectTodoHint => '从列表中选择一个待办。';

  @override
  String get noDetails => '暂无详情。';

  @override
  String get attachments => '附件';

  @override
  String get noAttachments => '暂无附件。';

  @override
  String get attach => '添加附件';

  @override
  String get complete => '完成';

  @override
  String get reopen => '重新打开';

  @override
  String get delete => '删除';

  @override
  String get pin => '置顶';

  @override
  String get edit => '编辑';

  @override
  String get remove => '移除';

  @override
  String failedLoadTodos(Object error) {
    return '加载待办失败：$error';
  }

  @override
  String failedLoadDetails(Object error) {
    return '加载详情失败：$error';
  }

  @override
  String failedLoadAttachments(Object error) {
    return '加载附件失败：$error';
  }

  @override
  String get newTodoTitle => '新建待办';

  @override
  String get editTodoTitle => '编辑待办';

  @override
  String get close => '关闭';

  @override
  String get titleLabel => '标题';

  @override
  String get titleHint => '你需要做什么？';

  @override
  String get detailsLabel => '详情';

  @override
  String get detailsHint => '备注、上下文、清单…';

  @override
  String get priorityLabel => '优先级';

  @override
  String get priorityShort => '优先级';

  @override
  String get criticalLabel => '紧急程度';

  @override
  String get criticalShort => '紧急';

  @override
  String get importantLabel => '重要程度';

  @override
  String get importantShort => '重要';

  @override
  String get pinnedLabel => '已置顶';

  @override
  String get dueLabel => '到期';

  @override
  String get dueShort => '到期';

  @override
  String get atLabel => '计划时间';

  @override
  String get atShort => '计划';

  @override
  String get none => '无';

  @override
  String get cancel => '取消';

  @override
  String get create => '创建';

  @override
  String get save => '保存';

  @override
  String get pinnedTodosEmpty => '没有置顶的待办。';

  @override
  String get unpin => '取消置顶';

  @override
  String get unpinDisableAot => '取消置顶（关闭置顶显示）';

  @override
  String get pinEnableAot => '置顶显示（总在最前）';
}
