use strum::EnumIter;

// https://www.yamahasynth.com/ask-a-question/relative-mode-for-control-knobs#reply-102919
#[repr(C)]
#[derive(Clone, Copy, EnumIter, PartialEq)]
pub enum Mode {
	Absolute,
	RelativeArturia1,
}

impl Mode {
	#[cfg(test)]
	pub fn is_absolute(&self) -> bool {
		match self {
			Mode::Absolute => true,
			_ => false,
		}
	}
}