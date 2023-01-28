use cbindgen::{Config, Language};
use std::env;
use std::path::PathBuf;

pub fn generate_bindings() {
    let crate_dir = env::var("CARGO_MANIFEST_DIR").unwrap();

    let package_name = env::var("CARGO_PKG_NAME").unwrap();
    let output_file = target_dir()
        .join(format!("{package_name}.lua"))
        .display()
        .to_string();

    let config = Config {
        language: Language::C,
        header: Some("local FFI = require(\"ffi\")\nFFI.cdef [[".to_string()),
        trailer: Some("]]".to_string()),
        no_includes: true,
        ..Default::default()
    };

    cbindgen::generate_with_config(crate_dir, config)
        .unwrap()
        .write_to_file(output_file);
}

fn target_dir() -> PathBuf {
    PathBuf::from(format!("../target/{}", env::var("PROFILE").unwrap()))
}
