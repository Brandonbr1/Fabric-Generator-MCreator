if(world instanceof ServerWorld) {
	Structure template=((ServerWorld) world).getStructureManager()
		.getStructureOrBlank(new Identifier("${modid}" ,"${field$schematic}"));

	if(template!=null){
		template.place((ServerWorld) world,
			new BlockPos((int) ${input$x},(int) ${input$y},(int) ${input$z}),
				new StructurePlacementData()
						.setRotation(BlockRotation.${field$rotation!'NONE'})
						.setMirror(BlockMirror.${field$mirror!'NONE'})
						.setChunkPosition(null)
						.setIgnoreEntities(false), ((World) world).random);
	}
}
