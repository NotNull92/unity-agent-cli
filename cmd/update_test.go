package cmd

import "testing"

func TestFindAsset(t *testing.T) {
	assets := []ghAsset{
		{Name: "unity-agent-cli-linux-amd64"},
		{Name: "unity-agent-cli-darwin-arm64"},
		{Name: "unity-agent-cli-windows-amd64.exe"},
	}

	// findAsset uses runtime.GOOS/GOARCH, so we just verify it returns something on the current platform
	got := findAsset(assets)
	if got == nil {
		t.Error("findAsset: should find asset for current platform")
	}

	empty := findAsset(nil)
	if empty != nil {
		t.Error("findAsset: should return nil for empty list")
	}

	noMatch := []ghAsset{{Name: "unity-agent-cli-plan9-mips"}}
	got = findAsset(noMatch)
	if got != nil {
		t.Error("findAsset: should return nil when no platform match")
	}
}
