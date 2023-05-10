use anyhow::Context;
use clap::Parser;
use ico::IconImage;
use image::{imageops, io::Reader as ImageReader};
use std::path::PathBuf;
use winres_edit::{resource_type, Id, Resources};

#[derive(Parser)]
#[command()]
struct Cli {
    #[arg(short, long, value_name = "FILE")]
    icon: PathBuf,
    #[arg(short, long, value_name = "FILE")]
    executable: PathBuf,
}

fn main() -> anyhow::Result<()> {
    let cli = Cli::parse();

    let mut resources = Resources::new(&cli.executable);
    resources
        .open()
        .context("Unable to open resources within executable")?;

    let image = ImageReader::open(cli.icon)
        .context("Could not open icon file")?
        .decode()
        .context("Could not decode icon file")?;

    let sizes: [u32; 6] = [16, 32, 48, 64, 128, 256];
    for (index, size) in sizes.into_iter().enumerate() {
        if let Some(resource) = resources.find(resource_type::ICON, Id::Integer(1 + index as u16)) {
            let resized_image = image
                .resize_exact(size, size, imageops::FilterType::Lanczos3)
                .to_rgba8();
            let icon_image = IconImage::from_rgba_data(size, size, resized_image.into_vec());
            let icon_dir_entry =
                ico::IconDirEntry::encode(&icon_image).context("Failed to encode image as icon")?;

            resource
                .replace(icon_dir_entry.data())
                .context("Could not replace icon resource content")?
                .update()
                .context("Could not update icon resource")?;
        }
    }

    resources.close();

    Ok(())
}
