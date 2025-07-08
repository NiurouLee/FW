namespace NFrameWork.Module.Combat
{
    public class SpellSkillActionAbility : Entity, IActionAbility
    {
        public bool Enable { get; set; }
        public Combat Owner => GetParent<Combat>();

        public bool TryMakeAction(out SpellSkillActionAbility action)
        {
            if (!Enable)
            {
                action = null;
            }
            else
            {
                action = Owner.AddChildren<SpellSkillAction>();
                action.ActionAbility = this;
                action.Creator = Owner;
            }
            return Enable;
        }
    }
    public class SpellSkillAction : Entity, IActionExecution, IUpdate
    {
        public SkillAbility SkillAbility;
        public SkillExecution SkillExecution;
        public Combat InputTarget;
        public Vector3 InputPoint;
        public float InputDirection;
        public Entity ActionAbility { get; set; }
        public EffectAssignAcion SourceAssignAction { get; set; }
        public Combat Creator { get; set; }
        public Combat Target { get; set; }

        public void FinishAction()
        {
            Dispose();
        }

        private void PreProcess()
        {
            Creator.GetggerActionPoint(ActionPointType.PreSpell, this)
        }

        public void SpellSkill()
        {
            PreProcess();
            SkillExecution = (SkillExecution)SkillAbility.CreateExecution();

            SkillExecution.ActionOccupy = actionOccupy;
            if (InputTarget != null)
            {
                SkillExecution.target.Add(InputTarget);
            }

            SkillExecution.InputPoint = InputPoint;
            SkillExecution.InputDirection = InputDirection;
            SkillExecution.BeginExecute();
        }
        public void Update()
        {
            if (SkillExecution != null)
            {
                if (SkillExecution.IsDispose)
                {
                    PostProcess();
                    FinishAction();
                }
            }
        }

        private void PoseProcess()
        {
            Creator.TriggerActionPoint(ActionPointType.PostSpell, this);
        }
    }
}

