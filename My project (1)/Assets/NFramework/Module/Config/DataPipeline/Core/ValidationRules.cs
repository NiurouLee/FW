using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;

namespace NFramework.Module.Config.DataPipeline
{
    /// <summary>
    /// 验证模式
    /// </summary>
    public enum ValidationMode
    {
        /// <summary>
        /// 普通验证模式 - 执行标准验证
        /// </summary>
        Normal = 0,

        /// <summary>
        /// 严格验证模式 - 执行更严格的验证规则
        /// </summary>
        Strict = 1,

        /// <summary>
        /// 宽松验证模式 - 允许更多的值类型和格式
        /// </summary>
        Lenient = 2
    }

    /// <summary>
    /// 验证规则集
    /// </summary>
    public class ValidationRules
    {
        #region 基本设置
        /// <summary>
        /// 是否在第一个错误时停止
        /// </summary>
        public bool StopOnFirstError { get; set; } = true;

        /// <summary>
        /// 是否验证引用
        /// </summary>
        public bool ValidateReferences { get; set; } = true;

        /// <summary>
        /// 是否验证数据类型
        /// </summary>
        public bool ValidateDataTypes { get; set; } = true;

        /// <summary>
        /// 验证模式
        /// </summary>
        public ValidationMode Mode { get; set; } = ValidationMode.Normal;
        #endregion

        #region 规则集合
        /// <summary>
        /// 字段验证规则
        /// </summary>
        public Dictionary<string, List<IValidationRule>> FieldRules { get; } = new Dictionary<string, List<IValidationRule>>();

        /// <summary>
        /// 全局验证规则
        /// </summary>
        public List<IValidationRule> GlobalRules { get; } = new List<IValidationRule>();

        /// <summary>
        /// 自定义验证规则
        /// </summary>
        public List<IValidationRule> CustomRules { get; } = new List<IValidationRule>();

        /// <summary>
        /// 条件验证规则
        /// </summary>
        public List<ConditionalValidationRule> ConditionalRules { get; } = new List<ConditionalValidationRule>();
        #endregion

        #region 内置规则
        /// <summary>
        /// 必填规则
        /// </summary>
        public static readonly ValidationRule Required = new ValidationRule
        {
            Name = "Required",
            ErrorMessage = "Field is required",
            Validator = value => value != null && !string.IsNullOrEmpty(value.ToString()),
            ErrorType = ValidationErrorType.Required,
            Severity = ValidationSeverity.Error
        };

        /// <summary>
        /// 最小长度规则
        /// </summary>
        public static ValidationRule MinLength(int length) => new ValidationRule
        {
            Name = "MinLength",
            ErrorMessage = $"Minimum length is {length}",
            Validator = value => value == null || value.ToString().Length >= length,
            ErrorType = ValidationErrorType.Length,
            Severity = ValidationSeverity.Error
        };

        /// <summary>
        /// 最大长度规则
        /// </summary>
        public static ValidationRule MaxLength(int length) => new ValidationRule
        {
            Name = "MaxLength",
            ErrorMessage = $"Maximum length is {length}",
            Validator = value => value == null || value.ToString().Length <= length,
            ErrorType = ValidationErrorType.Length,
            Severity = ValidationSeverity.Error
        };

        /// <summary>
        /// 正则表达式规则
        /// </summary>
        public static ValidationRule Pattern(string pattern, string message = null) => new ValidationRule
        {
            Name = "Pattern",
            ErrorMessage = message ?? $"Value does not match pattern: {pattern}",
            Validator = value => value == null || Regex.IsMatch(value.ToString(), pattern),
            ErrorType = ValidationErrorType.Pattern,
            Severity = ValidationSeverity.Error
        };

        /// <summary>
        /// 范围规则
        /// </summary>
        public static ValidationRule Range(object min, object max) => new ValidationRule
        {
            Name = "Range",
            ErrorMessage = $"Value must be between {min} and {max}",
            Validator = value =>
            {
                if (value == null) return true;
                if (value is IComparable comparable)
                {
                    return comparable.CompareTo(min) >= 0 && comparable.CompareTo(max) <= 0;
                }
                return true;
            },
            ErrorType = ValidationErrorType.Range,
            Severity = ValidationSeverity.Error
        };
        #endregion

        #region 构造函数
        /// <summary>
        /// 创建验证规则集
        /// </summary>
        public ValidationRules()
        {
            InitializeDefaultRules();
        }
        #endregion

        #region 公共方法
        /// <summary>
        /// 添加字段规则
        /// </summary>
        public void AddFieldRule(string fieldName, IValidationRule rule)
        {
            if (!FieldRules.ContainsKey(fieldName))
            {
                FieldRules[fieldName] = new List<IValidationRule>();
            }
            FieldRules[fieldName].Add(rule);
        }

        /// <summary>
        /// 添加全局规则
        /// </summary>
        public void AddGlobalRule(IValidationRule rule)
        {
            GlobalRules.Add(rule);
        }

        /// <summary>
        /// 添加条件规则
        /// </summary>
        public void AddConditionalRule(ConditionalValidationRule rule)
        {
            ConditionalRules.Add(rule);
        }

        /// <summary>
        /// 验证对象
        /// </summary>
        public ValidationResult Validate(object value, ValidationContext context = null)
        {
            var result = new ValidationResult();
            context = context ?? new ValidationContext();

            try
            {
                // 验证全局规则
                foreach (var rule in GlobalRules)
                {
                    ValidateRule(rule, value, result, context);
                    if (!result.IsValid && StopOnFirstError)
                        return result;
                }

                // 验证字段规则
                if (value != null)
                {
                    var type = value.GetType();
                    foreach (var property in type.GetProperties())
                    {
                        if (FieldRules.TryGetValue(property.Name, out var rules))
                        {
                            var propertyValue = property.GetValue(value);
                            foreach (var rule in rules)
                            {
                                ValidateRule(rule, propertyValue, result, context, property.Name);
                                if (!result.IsValid && StopOnFirstError)
                                    return result;
                            }
                        }
                    }
                }

                // 验证条件规则
                foreach (var rule in ConditionalRules)
                {
                    if (rule.Condition(value))
                    {
                        ValidateRule(rule.Rule, value, result, context);
                        if (!result.IsValid && StopOnFirstError)
                            return result;
                    }
                }

                // 验证自定义规则
                foreach (var rule in CustomRules)
                {
                    ValidateRule(rule, value, result, context);
                    if (!result.IsValid && StopOnFirstError)
                        return result;
                }
            }
            catch (Exception ex)
            {
                result.AddError(new ValidationError
                {
                    Message = $"Validation failed: {ex.Message}",
                    ErrorType = ValidationErrorType.Custom,
                    Severity = ValidationSeverity.Critical
                });
            }

            return result;
        }

        /// <summary>
        /// 克隆规则集
        /// </summary>
        public ValidationRules Clone()
        {
            var rules = new ValidationRules
            {
                StopOnFirstError = this.StopOnFirstError,
                ValidateReferences = this.ValidateReferences,
                ValidateDataTypes = this.ValidateDataTypes,
                Mode = this.Mode
            };

            // 复制字段规则
            foreach (var kvp in this.FieldRules)
            {
                rules.FieldRules[kvp.Key] = new List<IValidationRule>(kvp.Value);
            }

            // 复制全局规则
            rules.GlobalRules.AddRange(this.GlobalRules);

            // 复制自定义规则
            rules.CustomRules.AddRange(this.CustomRules);

            // 复制条件规则
            rules.ConditionalRules.AddRange(this.ConditionalRules);

            return rules;
        }
        #endregion

        #region 私有方法
        private void InitializeDefaultRules()
        {
            // 可以添加一些默认的验证规则
        }

        private void ValidateRule(IValidationRule rule, object value, ValidationResult result, ValidationContext context, string fieldName = null)
        {
            if (!rule.Validate(value, out string error))
            {
                result.AddError(new ValidationError
                {
                    Message = error,
                    Field = fieldName,
                    Value = value,
                    ErrorType = rule.ErrorType,
                    Severity = rule.Severity,
                    RuleName = rule.Name,
                    ValidationPath = context.ValidationPath
                });
            }
        }
        #endregion
    }

    #region 辅助类型
    /// <summary>
    /// 条件验证规则
    /// </summary>
    public class ConditionalValidationRule
    {
        /// <summary>
        /// 条件函数
        /// </summary>
        public Func<object, bool> Condition { get; set; }

        /// <summary>
        /// 验证规则
        /// </summary>
        public IValidationRule Rule { get; set; }
    }

    /// <summary>
    /// 验证规则
    /// </summary>
    public class ValidationRule : IValidationRule
    {
        /// <summary>
        /// 规则名称
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// 错误消息
        /// </summary>
        public string ErrorMessage { get; set; }

        /// <summary>
        /// 验证函数
        /// </summary>
        public Func<object, bool> Validator { get; set; }

        /// <summary>
        /// 错误类型
        /// </summary>
        public ValidationErrorType ErrorType { get; set; }

        /// <summary>
        /// 错误级别
        /// </summary>
        public ValidationSeverity Severity { get; set; }

        /// <summary>
        /// 执行验证
        /// </summary>
        public bool Validate(object value, out string error)
        {
            error = null;
            try
            {
                if (Validator != null && !Validator(value))
                {
                    error = ErrorMessage;
                    return false;
                }
                return true;
            }
            catch (Exception ex)
            {
                error = $"{ErrorMessage} (Error: {ex.Message})";
                return false;
            }
        }
    }

    /// <summary>
    /// 验证规则接口
    /// </summary>
    public interface IValidationRule
    {
        /// <summary>
        /// 规则名称
        /// </summary>
        string Name { get; }

        /// <summary>
        /// 错误类型
        /// </summary>
        ValidationErrorType ErrorType { get; }

        /// <summary>
        /// 错误级别
        /// </summary>
        ValidationSeverity Severity { get; }

        /// <summary>
        /// 执行验证
        /// </summary>
        bool Validate(object value, out string error);
    }
    #endregion
}
