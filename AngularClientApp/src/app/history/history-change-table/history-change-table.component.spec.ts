import { ComponentFixture, TestBed } from '@angular/core/testing';

import { HistoryChangeTableComponent } from './history-change-table.component';

describe('HistoryChangeTableComponent', () => {
  let component: HistoryChangeTableComponent;
  let fixture: ComponentFixture<HistoryChangeTableComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ HistoryChangeTableComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(HistoryChangeTableComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
