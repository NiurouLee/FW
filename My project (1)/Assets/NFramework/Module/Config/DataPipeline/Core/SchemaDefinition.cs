using System;
using System.Collections.Generic;
using System.Linq;

namespace NFramework.Module.Config.DataPipeline
{
    /// <summary>
    /// Schema定义
    /// </summary>
    public class SchemaDefinition
    {
        #region 基本信息
        /// <summary>
        /// Schema名称
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// Schema命名空间
        /// </summary>
        public string Namespace { get; set; }

        /// <summary>
        /// Schema描述
        /// </summary>
        public string Description { get; set; }

        /// <summary>
        /// Schema版本
        /// </summary>
        public string Version { get; set; }

        /// <summary>
        /// 作者
        /// </summary>
        public string Author { get; set; }

        /// <summary>
        /// 创建时间
        /// </summary>
        public DateTime CreatedTime { get; set; }

        /// <summary>
        /// 最后修改时间
        /// </summary>
        public DateTime LastModifiedTime { get; set; }
        #endregion

        #region 字段和关系
        /// <summary>
        /// 字段定义列表
        /// </summary>
        public List<FieldDefinition> Fields { get; set; } = new List<FieldDefinition>();

        /// <summary>
        /// 主键字段列表
        /// </summary>
        public List<string> PrimaryKeys { get; set; } = new List<string>();

        /// <summary>
        /// 索引定义列表
        /// </summary>
        public List<IndexDefinition> Indexes { get; set; } = new List<IndexDefinition>();

        /// <summary>
        /// 外键关系列表
        /// </summary>
        public List<ForeignKeyDefinition> ForeignKeys { get; set; } = new List<ForeignKeyDefinition>();

        /// <summary>
        /// 唯一约束列表
        /// </summary>
        public List<UniqueConstraint> UniqueConstraints { get; set; } = new List<UniqueConstraint>();
        #endregion

        #region 元数据
        /// <summary>
        /// 元数据
        /// </summary>
        public Dictionary<string, object> Metadata { get; set; } = new Dictionary<string, object>();

        /// <summary>
        /// Schema选项
        /// </summary>
        public SchemaOptions Options { get; set; } = new SchemaOptions();

        /// <summary>
        /// 注释列表
        /// </summary>
        public List<string> Comments { get; set; } = new List<string>();

        /// <summary>
        /// 导入列表
        /// </summary>
        public List<string> Imports { get; set; } = new List<string>();

        /// <summary>
        /// 基类列表
        /// </summary>
        public List<string> BaseTypes { get; set; } = new List<string>();

        /// <summary>
        /// 接口列表
        /// </summary>
        public List<string> Interfaces { get; set; } = new List<string>();
        #endregion

        #region 验证规则
        /// <summary>
        /// 验证规则列表
        /// </summary>
        public List<ValidationRule> ValidationRules { get; set; } = new List<ValidationRule>();

        /// <summary>
        /// 业务规则列表
        /// </summary>
        public List<BusinessRule> BusinessRules { get; set; } = new List<BusinessRule>();

        /// <summary>
        /// 数据转换规则列表
        /// </summary>
        public List<TransformationRule> TransformationRules { get; set; } = new List<TransformationRule>();
        #endregion

        #region 构造函数
        /// <summary>
        /// 创建Schema定义
        /// </summary>
        public SchemaDefinition()
        {
            CreatedTime = DateTime.Now;
            LastModifiedTime = DateTime.Now;
            InitializeDefaultOptions();
        }

        /// <summary>
        /// 使用名称和命名空间创建Schema定义
        /// </summary>
        public SchemaDefinition(string name, string nameSpace) : this()
        {
            Name = name;
            Namespace = nameSpace;
        }
        #endregion

        #region 公共方法
        /// <summary>
        /// 添加字段
        /// </summary>
        public void AddField(FieldDefinition field)
        {
            if (field == null) throw new ArgumentNullException(nameof(field));
            if (Fields.Any(f => f.Name == field.Name))
                throw new InvalidOperationException($"Field '{field.Name}' already exists");

            Fields.Add(field);
            LastModifiedTime = DateTime.Now;
        }

        /// <summary>
        /// 添加索引
        /// </summary>
        public void AddIndex(IndexDefinition index)
        {
            if (index == null) throw new ArgumentNullException(nameof(index));
            if (Indexes.Any(i => i.Name == index.Name))
                throw new InvalidOperationException($"Index '{index.Name}' already exists");

            Indexes.Add(index);
            LastModifiedTime = DateTime.Now;
        }

        /// <summary>
        /// 添加外键
        /// </summary>
        public void AddForeignKey(ForeignKeyDefinition foreignKey)
        {
            if (foreignKey == null) throw new ArgumentNullException(nameof(foreignKey));
            if (ForeignKeys.Any(f => f.Name == foreignKey.Name))
                throw new InvalidOperationException($"Foreign key '{foreignKey.Name}' already exists");

            ForeignKeys.Add(foreignKey);
            LastModifiedTime = DateTime.Now;
        }

        /// <summary>
        /// 添加验证规则
        /// </summary>
        public void AddValidationRule(ValidationRule rule)
        {
            if (rule == null) throw new ArgumentNullException(nameof(rule));
            ValidationRules.Add(rule);
            LastModifiedTime = DateTime.Now;
        }

        /// <summary>
        /// 验证Schema定义
        /// </summary>
        public bool Validate(out List<string> errors)
        {
            errors = new List<string>();

            // 验证基本信息
            if (string.IsNullOrEmpty(Name))
                errors.Add("Schema name is required");
            if (string.IsNullOrEmpty(Namespace))
                errors.Add("Schema namespace is required");

            // 验证字段
            if (Fields.Count == 0)
                errors.Add("At least one field is required");

            foreach (var field in Fields)
            {
                if (string.IsNullOrEmpty(field.Name))
                    errors.Add($"Field name is required for field at index {Fields.IndexOf(field)}");
                if (string.IsNullOrEmpty(field.Type))
                    errors.Add($"Field type is required for field '{field.Name}'");
            }

            // 验证主键
            if (PrimaryKeys.Count > 0)
            {
                foreach (var pk in PrimaryKeys)
                {
                    if (!Fields.Any(f => f.Name == pk))
                        errors.Add($"Primary key field '{pk}' does not exist");
                }
            }

            // 验证索引
            foreach (var index in Indexes)
            {
                foreach (var field in index.Fields)
                {
                    if (!Fields.Any(f => f.Name == field))
                        errors.Add($"Index field '{field}' in index '{index.Name}' does not exist");
                }
            }

            // 验证外键
            foreach (var fk in ForeignKeys)
            {
                if (!Fields.Any(f => f.Name == fk.SourceField))
                    errors.Add($"Foreign key source field '{fk.SourceField}' in '{fk.Name}' does not exist");
            }

            return errors.Count == 0;
        }

        /// <summary>
        /// 克隆Schema定义
        /// </summary>
        public SchemaDefinition Clone()
        {
            var schema = new SchemaDefinition
            {
                Name = this.Name,
                Namespace = this.Namespace,
                Description = this.Description,
                Version = this.Version,
                Author = this.Author,
                CreatedTime = this.CreatedTime,
                LastModifiedTime = this.LastModifiedTime
            };

            // 复制字段
            foreach (var field in Fields)
            {
                schema.Fields.Add(field.Clone());
            }

            // 复制主键
            schema.PrimaryKeys.AddRange(PrimaryKeys);

            // 复制索引
            foreach (var index in Indexes)
            {
                schema.Indexes.Add(index.Clone());
            }

            // 复制外键
            foreach (var fk in ForeignKeys)
            {
                schema.ForeignKeys.Add(fk.Clone());
            }

            // 复制唯一约束
            foreach (var uc in UniqueConstraints)
            {
                schema.UniqueConstraints.Add(uc.Clone());
            }

            // 复制元数据
            foreach (var meta in Metadata)
            {
                schema.Metadata[meta.Key] = meta.Value;
            }

            // 复制选项
            schema.Options = this.Options.Clone();

            // 复制列表
            schema.Comments.AddRange(Comments);
            schema.Imports.AddRange(Imports);
            schema.BaseTypes.AddRange(BaseTypes);
            schema.Interfaces.AddRange(Interfaces);

            // 复制规则
            foreach (var rule in ValidationRules)
            {
                schema.ValidationRules.Add(rule.Clone());
            }

            foreach (var rule in BusinessRules)
            {
                schema.BusinessRules.Add(rule.Clone());
            }

            foreach (var rule in TransformationRules)
            {
                schema.TransformationRules.Add(rule.Clone());
            }

            return schema;
        }
        #endregion

        #region 私有方法
        private void InitializeDefaultOptions()
        {
            Options.GenerateConstructor = true;
            Options.GenerateProperties = true;
            Options.GenerateValidation = true;
            Options.GenerateDocumentation = true;
        }
        #endregion
    }

    #region 辅助类型
    /// <summary>
    /// 索引定义
    /// </summary>
    public class IndexDefinition
    {
        /// <summary>
        /// 索引名称
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// 索引字段列表
        /// </summary>
        public List<string> Fields { get; set; } = new List<string>();

        /// <summary>
        /// 是否唯一索引
        /// </summary>
        public bool IsUnique { get; set; }

        /// <summary>
        /// 索引类型
        /// </summary>
        public string Type { get; set; }

        /// <summary>
        /// 克隆索引定义
        /// </summary>
        public IndexDefinition Clone()
        {
            return new IndexDefinition
            {
                Name = this.Name,
                Fields = new List<string>(this.Fields),
                IsUnique = this.IsUnique,
                Type = this.Type
            };
        }
    }

    /// <summary>
    /// 外键定义
    /// </summary>
    public class ForeignKeyDefinition
    {
        /// <summary>
        /// 外键名称
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// 源字段
        /// </summary>
        public string SourceField { get; set; }

        /// <summary>
        /// 引用表
        /// </summary>
        public string ReferenceTable { get; set; }

        /// <summary>
        /// 引用字段
        /// </summary>
        public string ReferenceField { get; set; }

        /// <summary>
        /// 删除时操作
        /// </summary>
        public ForeignKeyAction OnDelete { get; set; }

        /// <summary>
        /// 更新时操作
        /// </summary>
        public ForeignKeyAction OnUpdate { get; set; }

        /// <summary>
        /// 克隆外键定义
        /// </summary>
        public ForeignKeyDefinition Clone()
        {
            return new ForeignKeyDefinition
            {
                Name = this.Name,
                SourceField = this.SourceField,
                ReferenceTable = this.ReferenceTable,
                ReferenceField = this.ReferenceField,
                OnDelete = this.OnDelete,
                OnUpdate = this.OnUpdate
            };
        }
    }

    /// <summary>
    /// 唯一约束
    /// </summary>
    public class UniqueConstraint
    {
        /// <summary>
        /// 约束名称
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// 约束字段列表
        /// </summary>
        public List<string> Fields { get; set; } = new List<string>();

        /// <summary>
        /// 克隆唯一约束
        /// </summary>
        public UniqueConstraint Clone()
        {
            return new UniqueConstraint
            {
                Name = this.Name,
                Fields = new List<string>(this.Fields)
            };
        }
    }

    /// <summary>
    /// Schema选项
    /// </summary>
    public class SchemaOptions
    {
        /// <summary>
        /// 是否生成构造函数
        /// </summary>
        public bool GenerateConstructor { get; set; }

        /// <summary>
        /// 是否生成属性
        /// </summary>
        public bool GenerateProperties { get; set; }

        /// <summary>
        /// 是否生成验证
        /// </summary>
        public bool GenerateValidation { get; set; }

        /// <summary>
        /// 是否生成文档
        /// </summary>
        public bool GenerateDocumentation { get; set; }

        /// <summary>
        /// 访问级别
        /// </summary>
        public AccessLevel AccessLevel { get; set; }

        /// <summary>
        /// 序列化选项
        /// </summary>
        public SerializationOptions SerializationOptions { get; set; }

        /// <summary>
        /// 克隆Schema选项
        /// </summary>
        public SchemaOptions Clone()
        {
            return new SchemaOptions
            {
                GenerateConstructor = this.GenerateConstructor,
                GenerateProperties = this.GenerateProperties,
                GenerateValidation = this.GenerateValidation,
                GenerateDocumentation = this.GenerateDocumentation,
                AccessLevel = this.AccessLevel,
                SerializationOptions = this.SerializationOptions?.Clone()
            };
        }
    }

    /// <summary>
    /// 业务规则
    /// </summary>
    public class BusinessRule
    {
        /// <summary>
        /// 规则名称
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// 规则描述
        /// </summary>
        public string Description { get; set; }

        /// <summary>
        /// 规则表达式
        /// </summary>
        public string Expression { get; set; }

        /// <summary>
        /// 错误消息
        /// </summary>
        public string ErrorMessage { get; set; }

        /// <summary>
        /// 克隆业务规则
        /// </summary>
        public BusinessRule Clone()
        {
            return new BusinessRule
            {
                Name = this.Name,
                Description = this.Description,
                Expression = this.Expression,
                ErrorMessage = this.ErrorMessage
            };
        }
    }

    /// <summary>
    /// 数据转换规则
    /// </summary>
    public class TransformationRule
    {
        /// <summary>
        /// 规则名称
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// 源字段
        /// </summary>
        public string SourceField { get; set; }

        /// <summary>
        /// 目标字段
        /// </summary>
        public string TargetField { get; set; }

        /// <summary>
        /// 转换表达式
        /// </summary>
        public string Expression { get; set; }

        /// <summary>
        /// 克隆转换规则
        /// </summary>
        public TransformationRule Clone()
        {
            return new TransformationRule
            {
                Name = this.Name,
                SourceField = this.SourceField,
                TargetField = this.TargetField,
                Expression = this.Expression
            };
        }
    }

    /// <summary>
    /// 外键操作
    /// </summary>
    public enum ForeignKeyAction
    {
        /// <summary>
        /// 无操作
        /// </summary>
        NoAction,

        /// <summary>
        /// 级联
        /// </summary>
        Cascade,

        /// <summary>
        /// 设置为空
        /// </summary>
        SetNull,

        /// <summary>
        /// 设置为默认值
        /// </summary>
        SetDefault,

        /// <summary>
        /// 限制
        /// </summary>
        Restrict
    }
    #endregion
}
