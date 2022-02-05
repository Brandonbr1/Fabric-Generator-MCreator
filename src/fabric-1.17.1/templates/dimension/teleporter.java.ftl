<#--
 # MCreator (https://mcreator.net/)
 # Copyright (C) 2012-2020, Pylo
 # Copyright (C) 2020-2021, Pylo, opensource contributors
 # Copyright (C) 2020-2022, Goldorion, opensource contributors
 # 
 # This program is free software: you can redistribute it and/or modify
 # it under the terms of the GNU General Public License as published by
 # the Free Software Foundation, either version 3 of the License, or
 # (at your option) any later version.
 # 
 # This program is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 # 
 # You should have received a copy of the GNU General Public License
 # along with this program.  If not, see <https://www.gnu.org/licenses/>.
 # 
 # Additional permission for code generator templates (*.ftl files)
 # 
 # As a special exception, you may create a larger work that contains part or 
 # all of the MCreator code generator templates (*.ftl files) and distribute 
 # that work under terms of your choice, so long as that work isn't itself a 
 # template for code generation. Alternatively, if you modify or redistribute 
 # the template itself, you may (at your option) remove this special exception, 
 # which will cause the template and the resulting code generator output files 
 # to be licensed under the GNU General Public License without this special 
 # exception.
-->

<#-- @formatter:off -->
<#include "../mcitems.ftl">

package ${package}.world.teleporter;

@Mod.EventBusSubscriber(bus = Mod.EventBusSubscriber.Bus.MOD) public class ${name}Teleporter implements ITeleporter {

	public static final TicketType<BlockPos> CUSTOM_PORTAL = TicketType.create("${registryname}_portal", Vec3i::compareTo, 300);

	public static PoiType poi = null;

	@SubscribeEvent public static void registerPointOfInterest(RegistryEvent.Register<PoiType> event) {
		poi = new PoiType("${registryname}_portal", Sets.newHashSet(ImmutableSet.copyOf(${JavaModName}Blocks.${registryname?upper_case}_PORTAL
								.getStateDefinition().getPossibleStates())), 0, 1).setRegistryName("${registryname}_portal");
		ForgeRegistries.POI_TYPES.register(poi);
	}

	private final ServerLevel level;
	private final BlockPos entityEnterPos;

	public ${name}Teleporter(ServerLevel worldServer, BlockPos entityEnterPos) {
		this.level = worldServer;
		this.entityEnterPos = entityEnterPos;
	}
	
	public Optional<BlockUtil.FoundRectangle> findPortalAround(BlockPos blockPos, boolean bl) {
        PoiManager poiManager = this.level.getPoiManager();
        int i = bl ? 16 : 128;
        poiManager.ensureLoadedAndValid(this.level, blockPos, i);
        Optional<PoiRecord> optional = poiManager.getInSquare(poiType -> poiType == poi, blockPos, i, PoiManager.Occupancy.ANY).sorted(Comparator.comparingDouble(poiRecord -> ((PoiRecord) poiRecord).getPos().distSqr(blockPos)).thenComparingInt(pr -> ((PoiRecord) pr).getPos().getY())).filter(poiRecord -> this.level.getBlockState(poiRecord.getPos()).hasProperty(BlockStateProperties.HORIZONTAL_AXIS)).findFirst();
        return optional.map(poiRecord -> {
            BlockPos blockPos2 = poiRecord.getPos();
            this.level.getChunkSource().addRegionTicket(CUSTOM_PORTAL, new ChunkPos(blockPos2), 3, blockPos2);
            BlockState blockState = this.level.getBlockState(blockPos2);
        return BlockUtil.getLargestRectangleAround(blockPos2, blockState.getValue(BlockStateProperties.HORIZONTAL_AXIS), 21, Direction.Axis.Y, 21, bp -> this.level.getBlockState((BlockPos) bp) == blockState);
        });
    }

    public Optional<BlockUtil.FoundRectangle> createPortal(BlockPos blockPos, Direction.Axis axis) {
        int m,l,k;
        Direction direction = Direction.get(Direction.AxisDirection.POSITIVE, axis);
        double d = -1.0;
        BlockPos blockPos2 = null;
        double e = -1.0;
        BlockPos blockPos3 = null;
        WorldBorder worldBorder = this.level.getWorldBorder();
        int i = Math.min(this.level.getMaxBuildHeight(), this.level.getMinBuildHeight() + this.level.getLogicalHeight()) - 1;
        BlockPos.MutableBlockPos mutableBlockPos = blockPos.mutable();
        for (BlockPos.MutableBlockPos mutableBlockPos2 : BlockPos.spiralAround(blockPos, 16, Direction.EAST, Direction.SOUTH)) {
            int j = Math.min(i, this.level.getHeight(Heightmap.Types.MOTION_BLOCKING, mutableBlockPos2.getX(), mutableBlockPos2.getZ()));
            k = 1;
            if (!worldBorder.isWithinBounds(mutableBlockPos2) || !worldBorder.isWithinBounds(mutableBlockPos2.move(direction, 1)))
                continue;
            mutableBlockPos2.move(direction.getOpposite(), 1);
            for (l = j; l >= this.level.getMinBuildHeight(); --l) {
                int n;
                mutableBlockPos2.setY(l);
                if (!this.level.isEmptyBlock(mutableBlockPos2)) continue;
                m = l;
                while (l > this.level.getMinBuildHeight() && this.level.isEmptyBlock(mutableBlockPos2.move(Direction.DOWN))) {
                    --l;
                }
                if (l + 4 > i || (n = m - l) > 0 && n < 3) continue;
                mutableBlockPos2.setY(l);
                if (!this.canHostFrame(mutableBlockPos2, mutableBlockPos, direction, 0)) continue;
                double f = blockPos.distSqr(mutableBlockPos2);
                if (this.canHostFrame(mutableBlockPos2, mutableBlockPos, direction, -1) && this.canHostFrame(mutableBlockPos2, mutableBlockPos, direction, 1) && (d == -1.0 || d > f)) {
                    d = f;
                    blockPos2 = mutableBlockPos2.immutable();
                }
                if (d != -1.0 || e != -1.0 && !(e > f)) continue;
                e = f;
                blockPos3 = mutableBlockPos2.immutable();
            }
        }
        if (d == -1.0 && e != -1.0) {
            blockPos2 = blockPos3;
            d = e;
        }
        if (d == -1.0) {
            int mutableBlockPos2 = i - 9;
            int o = Math.max(this.level.getMinBuildHeight() - -1, 70);
            if (mutableBlockPos2 < o) {
                return Optional.empty();
            }
            blockPos2 = new BlockPos(blockPos.getX(), Mth.clamp(blockPos.getY(), o, mutableBlockPos2), blockPos.getZ()).immutable();
            Direction j = direction.getClockWise();
            if (!worldBorder.isWithinBounds(blockPos2)) {
                return Optional.empty();
            }
            for (k = -1; k < 2; ++k) {
                for (l = 0; l < 2; ++l) {
                    for (m = -1; m < 3; ++m) {
                        BlockState n = m < 0 ? ${mappedBlockToBlock(data.portalFrame)?string}.defaultBlockState() : Blocks.AIR.defaultBlockState();
                        mutableBlockPos.setWithOffset(blockPos2, l * direction.getStepX() + k * j.getStepX(), m, l * direction.getStepZ() + k * j.getStepZ());
                        this.level.setBlockAndUpdate(mutableBlockPos, n);
                    }
                }
            }
        }
        for (int o = -1; o < 3; ++o) {
            for (int mutableBlockPos2 = -1; mutableBlockPos2 < 4; ++mutableBlockPos2) {
                if (o != -1 && o != 2 && mutableBlockPos2 != -1 && mutableBlockPos2 != 3) continue;
                mutableBlockPos.setWithOffset(blockPos2, o * direction.getStepX(), mutableBlockPos2, o * direction.getStepZ());
                this.level.setBlock(mutableBlockPos, ${mappedBlockToBlock(data.portalFrame)?string}.defaultBlockState(), 3);
            }
        }
        BlockState o = (BlockState) ${JavaModName + "Blocks." + registryname?upper_case + "_PORTAL"}.defaultBlockState().setValue(NetherPortalBlock.AXIS, axis);
        for (int mutableBlockPos2 = 0; mutableBlockPos2 < 2; ++mutableBlockPos2) {
            for (int j = 0; j < 3; ++j) {
                mutableBlockPos.setWithOffset(blockPos2, mutableBlockPos2 * direction.getStepX(), j, mutableBlockPos2 * direction.getStepZ());
                this.level.setBlock(mutableBlockPos, o, 18);
            }
        }
        return Optional.of(new BlockUtil.FoundRectangle(blockPos2.immutable(), 2, 3));
    }

    private boolean canHostFrame(BlockPos blockPos, BlockPos.MutableBlockPos mutableBlockPos, Direction direction, int i) {
        Direction direction2 = direction.getClockWise();
        for (int j = -1; j < 3; ++j) {
            for (int k = -1; k < 4; ++k) {
                mutableBlockPos.setWithOffset(blockPos, direction.getStepX() * j + direction2.getStepX() * i, k, direction.getStepZ() * j + direction2.getStepZ() * i);
            if (k < 0 && !this.level.getBlockState(mutableBlockPos).getMaterial().isSolid()) {
                return false;
            }
            if (k < 0 || this.level.isEmptyBlock(mutableBlockPos)) continue;
                return false;
            }
        }
        return true;
    }

	@Override
	public Entity placeEntity(Entity entity, ServerLevel ServerLevel, ServerLevel server, float yaw,
			Function<Boolean, Entity> repositionEntity) {
		PortalInfo portalinfo = getPortalInfo(entity, server);

		if (entity instanceof ServerPlayer player) {
			player.setLevel(server);
			server.addDuringPortalTeleport(player);

			entity.setYRot(portalinfo.yRot % 360.0F);
			entity.setXRot(portalinfo.xRot % 360.0F);

			entity.moveTo(portalinfo.pos.x, portalinfo.pos.y, portalinfo.pos.z);

			return entity;
		} else {
			Entity entityNew = entity.getType().create(server);
			if (entityNew != null) {
				entityNew.restoreFrom(entity);
				entityNew.moveTo(portalinfo.pos.x, portalinfo.pos.y, portalinfo.pos.z, portalinfo.yRot, entityNew.getXRot());
				entityNew.setDeltaMovement(portalinfo.speed);
				server.addDuringTeleport(entityNew);
			}
			return entityNew;
		}
	}

	private PortalInfo getPortalInfo(Entity entity, ServerLevel server) {
		WorldBorder worldborder = server.getWorldBorder();
		double d0 = Math.max(-2.9999872E7D, worldborder.getMinX() + 16.);
		double d1 = Math.max(-2.9999872E7D, worldborder.getMinZ() + 16.);
		double d2 = Math.min(2.9999872E7D, worldborder.getMaxX() - 16.);
		double d3 = Math.min(2.9999872E7D, worldborder.getMaxZ() - 16.);
		double d4 = DimensionType.getTeleportationScale(entity.level.dimensionType(), server.dimensionType());
		BlockPos blockpos1 = new BlockPos(Mth.clamp(entity.getX() * d4, d0, d2), entity.getY(),
				Mth.clamp(entity.getZ() * d4, d1, d3));
		return this.getPortalRepositioner(entity, blockpos1).map(repositioner -> {
			BlockState blockstate = entity.level.getBlockState(this.entityEnterPos);
			Direction.Axis direction$axis;
			Vec3 vector3d;

			if (blockstate.hasProperty(BlockStateProperties.HORIZONTAL_AXIS)) {
				direction$axis = blockstate.getValue(BlockStateProperties.HORIZONTAL_AXIS);
				BlockUtil.FoundRectangle teleportationrepositioner$result = BlockUtil.getLargestRectangleAround(this.entityEnterPos, direction$axis, 21, Direction.Axis.Y, 21,
								pos -> entity.level.getBlockState(pos) == blockstate);
				vector3d = ${name}PortalShape.getRelativePosition(teleportationrepositioner$result, direction$axis, entity.position(), entity.getDimensions(entity.getPose()));
			} else {
				direction$axis = Direction.Axis.X;
				vector3d = new Vec3(0.5, 0, 0);
			}

			return ${name}PortalShape.createPortalInfo(server, repositioner, direction$axis, vector3d, entity.getDimensions(entity.getPose()),
							entity.getDeltaMovement(), entity.getYRot(), entity.getXRot());
		}).orElse(new PortalInfo(entity.position(), Vec3.ZERO, entity.getYRot(), entity.getXRot()));
	}

	protected Optional<BlockUtil.FoundRectangle> getPortalRepositioner(Entity entity, BlockPos pos) {
		Optional<BlockUtil.FoundRectangle> optional = this.findPortalAround(pos, false);

		if (entity instanceof ServerPlayer) {
			if (optional.isPresent()) {
				return optional;
			} else {
				Direction.Axis direction$axis = entity.level.getBlockState(this.entityEnterPos).getOptionalValue(NetherPortalBlock.AXIS).orElse(Direction.Axis.X);
				return this.createPortal(pos, direction$axis);
			}
		} else {
			return optional;
		}
	}

}

<#-- @formatter:on -->