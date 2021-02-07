use strum::EnumIter;

// https://www.yamahasynth.com/ask-a-question/relative-mode-for-control-knobs#reply-102919
#[repr(C)]
#[derive(Clone, Copy, Debug, EnumIter, PartialEq)]
pub enum Mode {
	Absolute,
	RelativeArturia1,
}
