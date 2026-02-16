import {
  Controller,
  Get,
  Post,
  Delete,
  Param,
  Body,
  Headers,
  Logger,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiParam, ApiHeader } from '@nestjs/swagger';
import { JourneysService } from './journeys.service';
import { ApiResponseDto } from '../common/dto/api-response.dto';
import { CreateJourneyDto } from './dto/journey.dto';

@ApiTags('Journeys')
@Controller('api/v1/journeys')
export class JourneysController {
  private readonly logger = new Logger(JourneysController.name);
  private readonly defaultUserId = '00000000-0000-0000-0000-000000000001';

  private getUserId(authHeader?: string): string {
    return this.defaultUserId;
  }

  constructor(private readonly journeysService: JourneysService) {}

  @Get()
  @ApiOperation({ summary: "Get user's journeys (upcoming + past)" })
  @ApiHeader({ name: 'Authorization', required: false })
  async getUserJourneys(@Headers('authorization') auth?: string) {
    const userId = this.getUserId(auth);
    const journeys = await this.journeysService.getUserJourneys(userId);
    return new ApiResponseDto(journeys);
  }

  @Post()
  @ApiOperation({ summary: 'Add a journey' })
  @ApiHeader({ name: 'Authorization', required: false })
  async createJourney(
    @Body() dto: CreateJourneyDto,
    @Headers('authorization') auth?: string,
  ) {
    const userId = this.getUserId(auth);
    const journey = await this.journeysService.createJourney(userId, dto);
    return new ApiResponseDto(journey, 'Journey created');
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get journey detail' })
  @ApiParam({ name: 'id' })
  @ApiHeader({ name: 'Authorization', required: false })
  async getJourneyDetail(
    @Param('id') id: string,
    @Headers('authorization') auth?: string,
  ) {
    const userId = this.getUserId(auth);
    const journey = await this.journeysService.getJourneyDetail(id, userId);
    return new ApiResponseDto(journey);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Remove journey' })
  @ApiParam({ name: 'id' })
  @ApiHeader({ name: 'Authorization', required: false })
  async deleteJourney(
    @Param('id') id: string,
    @Headers('authorization') auth?: string,
  ) {
    const userId = this.getUserId(auth);
    await this.journeysService.deleteJourney(id, userId);
    return new ApiResponseDto(null, 'Journey removed');
  }
}
