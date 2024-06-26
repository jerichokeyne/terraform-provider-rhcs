package exec

import (
	"github.com/terraform-redhat/terraform-provider-rhcs/tests/utils/constants"
)

type KubeletConfigArgs struct {
	Cluster      *string `hcl:"cluster"`
	PodPidsLimit *int    `hcl:"pod_pids_limit"`
}

type KubeletConfigOutput struct {
	Cluster      string `json:"cluster_id,omitempty"`
	PodPidsLimit int    `json:"pod_pids_limit,omitempty"`
}

type KubeletConfigService interface {
	Init() error
	Plan(args *KubeletConfigArgs) (string, error)
	Apply(args *KubeletConfigArgs) (string, error)
	Output() (*KubeletConfigOutput, error)
	Destroy() (string, error)

	ReadTFVars() (*KubeletConfigArgs, error)
	DeleteTFVars() error
}

type kubeletConfigService struct {
	tfExecutor TerraformExecutor
}

func NewKubeletConfigService(manifestsDirs ...string) (KubeletConfigService, error) {
	manifestsDir := constants.KubeletConfigDir
	if len(manifestsDirs) > 0 {
		manifestsDir = manifestsDirs[0]
	}
	svc := &kubeletConfigService{
		tfExecutor: NewTerraformExecutor(manifestsDir),
	}
	err := svc.Init()
	return svc, err
}

func (svc *kubeletConfigService) Init() (err error) {
	_, err = svc.tfExecutor.RunTerraformInit()
	return
}

func (svc *kubeletConfigService) Plan(args *KubeletConfigArgs) (string, error) {
	return svc.tfExecutor.RunTerraformPlan(args)
}

func (svc *kubeletConfigService) Apply(args *KubeletConfigArgs) (string, error) {
	return svc.tfExecutor.RunTerraformApply(args)
}

func (svc *kubeletConfigService) Output() (*KubeletConfigOutput, error) {
	var output KubeletConfigOutput
	err := svc.tfExecutor.RunTerraformOutputIntoObject(&output)
	if err != nil {
		return nil, err
	}
	return &output, nil
}

func (svc *kubeletConfigService) Destroy() (string, error) {
	return svc.tfExecutor.RunTerraformDestroy()
}

func (svc *kubeletConfigService) ReadTFVars() (*KubeletConfigArgs, error) {
	args := &KubeletConfigArgs{}
	err := svc.tfExecutor.ReadTerraformVars(args)
	return args, err
}

func (svc *kubeletConfigService) DeleteTFVars() error {
	return svc.tfExecutor.DeleteTerraformVars()
}
